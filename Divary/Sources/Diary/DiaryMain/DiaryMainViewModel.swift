
//
//  DiaryMainViewModel.swift
//  Divary
//

import SwiftUI
import PhotosUI
import ImageIO
import UniformTypeIdentifiers
import RichTextKit
import Observation
import PencilKit
import Combine

@Observable /*@MainActor*/
class DiaryMainViewModel: Hashable {
    let id = UUID()
    
    var isLoading: Bool = false
    
    var blocks: [DiaryBlock] = []
    var selectedItems: [PhotosPickerItem] = []
    var editingTextBlock: DiaryBlock? = nil
    var editingImageBlock: DiaryBlock? = nil
    var richTextContext = RichTextContext()
    var forceUIUpdate: Bool = false
    var currentTextAlignment: NSTextAlignment = .left
    
    // 현재 커서 스타일 상태
    var currentFontSize: CGFloat = 16.0
    var currentFontName: String = "NanumSquareNeoTTF-cBd"
    var currentIsUnderlined: Bool = false
    var currentIsStrikethrough: Bool = false
    
    // 내부 상태 관리
    private var isApplyingStyle: Bool = false
    private var lastCursorPosition: Int = 0
    
    var savedDrawing: PKDrawing? = nil
    var drawingOffsetY: CGFloat = 0
    
    private var injected = false
    private var bag = Set<AnyCancellable>()
    private var diaryService: LogDiaryService?
    private var imageService: ImageService?
    private var token: String?
    
    // 저장
    private var currentLogId: Int = 0
    private var hasDiary: Bool = false // 서버에 일기 존재 여부(POST/PUT 분기)
    
    // 기존 이미지(파일 교체 안 함)는 temp가 비어 있어도 저장 허용
    var canSave: Bool {
        let imagesReady = blocks.allSatisfy { block in
            if case .image(let f) = block.content {
                let hasTemp = (f.tempFilename?.isEmpty == false)
                let isExistingImage = (f.originalData == nil)   // 서버에서 불러온 기존 이미지
                let isNewLocal = (f.originalData != nil)
                return hasTemp || isExistingImage || isNewLocal
            }
            return true
        }
        return imagesReady && diaryService != nil && (token?.isEmpty == false)
    }
    
    // 저장버튼 뷰에 내려주기 위한 파생 값
    var canSavePublic: Bool = false
    func recomputeCanSave() {
        canSavePublic = canSave
    }
    
    var hasUnsavedChanges: Bool = false
    var saveButtonEnabled: Bool { hasUnsavedChanges && canSave }
    
    // 변경 발생 시 호출
    private func markDirty() {
        hasUnsavedChanges = true
        recomputeCanSave()
    }
    
    // MARK: - Equatable & Hashable
    static func == (lhs: DiaryMainViewModel, rhs: DiaryMainViewModel) -> Bool {
        lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    // MARK: - API 연결
    func inject(diaryService: LogDiaryService, imageService: ImageService, token: String) {
        guard !injected else { return }
        self.diaryService = diaryService
        self.imageService = imageService
        self.token = token
        injected = true
        recomputeCanSave()
    }
    
    // 1) 서버에서 읽기
    func loadFromServer(logId: Int) {
        self.currentLogId = logId
        guard let diaryService, let token else { return }
        isLoading = true
        diaryService.getDiary(logId: logId, token: token)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] comp in
                self?.isLoading = false
                if case let .failure(err) = comp {
                    DebugLogger.error("getDiary error: \(err)")
                    Task { @MainActor in
                        self?.hasDiary = false // 생성 POST 으로
                    }
                }
            } receiveValue: { [weak self] dto in
                Task { @MainActor in
                    self?.applyServerDiary(dto)
                    self?.hasDiary = true // 수정 PUT 으로
                    self?.isLoading = false
                }
            }
            .store(in: &bag)
    }

    // 2) 응답 → 화면 상태 매핑
    @MainActor
    private func applyServerDiary(_ dto: DiaryResponseDTO) {
        var newBlocks: [DiaryBlock] = []

        for c in dto.contents {
            switch c.type {
            case .text:
                if let base64 = c.rtfData,
                   let data = Data(base64Encoded: base64),
                   let rich = RichTextContent(rtfData: data) {
                    newBlocks.append(DiaryBlock(content: .text(rich)))
                } else {
                    newBlocks.append(DiaryBlock(content: .text(RichTextContent())))
                }

            case .image:
                if let img = c.imageData {
                    let frame = mapFrameColor(from: img.frameColor)
                    // 원격 이미지는 우선 placeholder로 만들고, 필요하면 비동기로 로드해서 교체
                    let item = FramedImageContent(
                        image: Image(systemName: "photo"),
                        caption: img.caption,
                        frameColor: frame,
                        date: img.date
                    )
                    // 업로드/서버 경로 저장 (이후 저장 시 tempFilename으로 사용)
                    item.tempFilename = img.tempFilename
                    newBlocks.append(DiaryBlock(content: .image(item)))
                }
                
                if let s = self.blocks.compactMap({
                    if case let .image(f) = $0.content { return f.tempFilename } else { return nil }
                }).first, let u = URL(string: s) {
                    URLSession.shared.dataTask(with: u) { _, resp, err in
                        DebugLogger.log("IMG resp: \((resp as? HTTPURLResponse)?.statusCode ?? -1), err: \(err as Any)")
                    }.resume()
                }

            case .drawing:
                if let d = c.drawingData,
                   let bin = Data(base64Encoded: d.base64),
                   let pk = try? PKDrawing(data: bin) {
                    self.savedDrawing = pk
                    self.drawingOffsetY = d.scrollY
                }
            }
        }

        self.blocks = newBlocks
        self.recomputeCanSave()
        self.hasUnsavedChanges = false
        // 디버그: 첫 이미지 URL 확인
        if case let .image(f)? = self.blocks.first?.content {
            DebugLogger.log("tempFilename: \(f.tempFilename ?? "nil")")
        }
        DebugLogger.success("blocks: \(blocks.count), drawing: \(savedDrawing != nil)")
    }

    // frameColor: 서버는 "0","1",... 문자열 → 앱 enum으로 변환
    private func mapFrameColor(from raw: String) -> FrameColor {
//        if let i = Int(raw), let mapped = FrameColor(rawValue: i) {
//            return mapped
//        }
//        return .origin
        (Int(raw).flatMap { FrameColor(rawValue: $0) }) ?? .origin
    }
    
    private func makeRequestBody() -> DiaryRequestDTO {
        var items: [DiaryContentDTO] = []

        for block in blocks {
            switch block.content {
            case .text(let rich):
                let base64 = (rich.rtfData ?? Data()).base64EncodedString()
                items.append(.init(type: .text, rtfData: base64, imageData: nil, drawingData: nil))

            case .image(let f):
                // tempFilename 필수! (이미지 업로드 끝난 후 저장해야 함)
                guard let temp = f.tempFilename, !temp.isEmpty else { continue }
                let img = DiaryImageDataDTO(
                    tempFilename: temp,
                    caption: f.caption,
                    frameColor: String(f.frameColor.rawValue),
                    date: f.date
                )
                items.append(.init(type: .image, rtfData: nil, imageData: img, drawingData: nil))
            }
        }

        if let d = savedDrawing {
            let base64 = d.dataRepresentation().base64EncodedString()
            let draw = DiaryDrawingDataDTO(base64: base64, scrollY: drawingOffsetY)
            items.append(.init(type: .drawing, rtfData: nil, imageData: nil, drawingData: draw))
        }

        return DiaryRequestDTO(contents: items)
    }

    func manualSave() {
        // 편집 중인 텍스트를 먼저 커밋
        if editingTextBlock != nil {
            saveCurrentEditingBlock()
            // 선택: 커밋까지 같이
             commitEditingTextBlock()
        }
        guard canSave else {
            DebugLogger.warning("저장 불가: 이미지 업로드 미완료 또는 토큰/서비스 없음")
            return
        }
        guard let diaryService, let token else { return }

        let body = makeRequestBody()
        let isUpdate = hasDiary   // ← 이 값은 2단계에서 설정함

        let pub = isUpdate
            ? diaryService.updateDiary(logId: currentLogId, body: body, token: token)
            : diaryService.createDiary(logId: currentLogId, body: body, token: token)

        pub
            .receive(on: DispatchQueue.main)
            .sink { comp in
                if case let .failure(err) = comp { DebugLogger.error("manualSave error: \(err)") }
            } receiveValue: { [weak self] dto in
                Task { @MainActor in
                    self?.applyServerDiary(dto)  // 서버 정규화 반영
                    self?.hasDiary = true        // 최초 생성 후엔 항상 PUT
                }
                DebugLogger.success("저장 완료")
            }
            .store(in: &bag)
    }

    // MARK: - 사진 처리
    func makeFramedDTOs(from items: [PhotosPickerItem]) async -> [FramedImageContent] {
        let indexed = Array(items.enumerated())
        var temp = Array<FramedImageContent?>(repeating: nil, count: indexed.count)

        await withTaskGroup(of: (Int, FramedImageContent?) .self) { group in
            for (idx, item) in indexed {
                group.addTask { [weak self] in
                    guard let self else { return (idx, nil) }
                    guard
                        let data = try? await item.loadTransferable(type: Data.self),
                        let uiImage = UIImage(data: data)
                    else {
                        return (idx, nil)
                    }

                    let dateString = await self.formattedPhotoDateString(from: item)
                    let dto = FramedImageContent(
                        image: Image(uiImage: uiImage),
                        caption: "",
                        frameColor: .origin,
                        date: dateString
                    )
                    dto.originalData = data
                    return (idx, dto)
                }
            }

            for await (idx, dto) in group {
                temp[idx] = dto
            }
        }

        return temp.compactMap { $0 } // 실패 항목 제거
    }
    
    // 이미지 수정
    func updateImageBlock(id: UUID, to newContent: FramedImageContent) {
        guard let idx = blocks.firstIndex(where: { $0.id == id }) else { return }

        // 교체된 콘텐츠 반영
        blocks[idx].content = .image(newContent)

        // 새 파일로 바꾼 경우엔 임시 URL 다시 발급 필요
        let isReplacingFile = (newContent.originalData != nil)

        if isReplacingFile {
            // 업로드 전에는 비워두고 저장버튼 비활성화 유도
            newContent.tempFilename = nil
            recomputeCanSave()

            if let data = newContent.originalData, let token, let imageService {
                imageService.uploadTemp(files: [data], token: token)
                    .map { $0.first?.fileUrl ?? "" }
                    .receive(on: DispatchQueue.main)
                    .sink { comp in
                        if case let .failure(err) = comp {
                            DebugLogger.error("uploadTemp (edit) error: \(err)")
                        }
                    } receiveValue: { [weak self] url in
                        newContent.tempFilename = url
                        self?.recomputeCanSave()
                        self?.forceUIUpdate.toggle()
                    }
                    .store(in: &bag)
            }
        } else {
            // 캡션/프레임만 바꾼 경우
            recomputeCanSave()
        }

        // 필요 시 리렌더
        forceUIUpdate.toggle()
        markDirty()
    }
    
    func extractPhotoDate(from item: PhotosPickerItem) async -> Date? {
        do {
            // 1. 파일 URL 가져오기
            if let url = try await item.loadTransferable(type: URL.self) {
                let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil)
                guard let imageSource else { return nil }

                // 2. 메타데이터 읽기
                let metadata = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [CFString: Any]
                let exif = metadata?[kCGImagePropertyExifDictionary] as? [CFString: Any]

                // 3. 날짜 파싱
                if let dateTimeString = exif?[kCGImagePropertyExifDateTimeOriginal] as? String {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
                    return formatter.date(from: dateTimeString)
                }
            }
        } catch {
            DebugLogger.error("extractPhotoDate error: \(error)")
        }
        return nil
    }
    
    private let formatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "ko_KR") // 한글 기준 정렬
        df.dateFormat = "yyyy.M.d H:mm" // 2025.5.25 7:32
        return df
    }()
    
    func formattedPhotoDateString(from item: PhotosPickerItem) async -> String {
        if let date = await extractPhotoDate(from: item) {
            return formatter.string(from: date)
        } else {
            return formatter.string(from: Date())
        }
    }

    // MARK: - Block Management
    
    func addTextBlock() {
        let text = NSAttributedString(string: "")
        let content = RichTextContent(text: text)
        let block = DiaryBlock(content: .text(content))
        blocks.append(block)
        
        editingTextBlock = block
        richTextContext = content.context
        richTextContext.setAttributedString(to: text)
        richTextContext.fontSize = currentFontSize
        
        DispatchQueue.main.async {
            self.applyCurrentStyleToTypingAttributes()
        }
        markDirty()
    }

    func saveCurrentEditingBlock() {
        guard let block = editingTextBlock,
              case .text(let content) = block.content else { return }

        let newText = richTextContext.attributedString
        if !content.text.isEqual(to: newText) {
            content.text = newText
            content.context = richTextContext
            markDirty()
        }
    }

    func commitEditingTextBlock() {
        saveCurrentEditingBlock()
        editingTextBlock = nil
    }

    func addImages(_ images: [FramedImageContent]) {
        images.forEach { image in
            // 화면에 먼저 추가
            let block = DiaryBlock(content: .image(image))
            blocks.append(block)
            
            // 업로드
            if let data = image.originalData, let token, let imageService {
                imageService.uploadTemp(files: [data], token: token)
                    .map { $0.first?.fileUrl ?? "" }
                    .receive(on: DispatchQueue.main)
                    .sink { comp in
                        if case let .failure(err) = comp { DebugLogger.error("uploadTemp error: \(err)") }
                    } receiveValue: { [weak self] url in
                        image.tempFilename = url
                        self?.recomputeCanSave() // 업로드 후 재계산
                    }
                    .store(in: &bag)
            }
            else {
                recomputeCanSave() // 블록만 추가했을 때도
            }
        }
        markDirty()
    }

    func startEditing(_ block: DiaryBlock) {
        guard case .text(let content) = block.content else { return }

        // 1) 편집 컨텍스트에 현재 텍스트를 먼저 주입
        content.context.setAttributedString(to: content.text)

        // 2) 뷰모델 컨텍스트 교체
        self.richTextContext = content.context

        // 3) 마지막에 편집 모드 플래그 (뷰 스위치 트리거)
        self.editingTextBlock = block

        // 4) (선택) 스타일 동기화/포커스
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.syncStyleFromCurrentPosition()
            self.forceUIUpdate.toggle()
        }
    }

    func deleteBlock(_ block: DiaryBlock) {
        blocks.removeAll { $0.id == block.id }
        if editingTextBlock?.id == block.id {
            editingTextBlock = nil
        }
        markDirty()
    }

    // MARK: - Style Management
    
    func setFontSize(_ size: CGFloat) {
        currentFontSize = size
        applyFontSizeChange()
    }
    
    func setFontFamily(_ fontName: String) {
        currentFontName = fontName
        applyFontFamilyChange()
    }
    
    func setUnderline(_ isUnderlined: Bool) {
        currentIsUnderlined = isUnderlined
        applyUnderlineChange()
    }
    
    func setStrikethrough(_ isStrikethrough: Bool) {
        currentIsStrikethrough = isStrikethrough
        applyStrikethroughChange()
    }
    
    func setTextAlignment(_ alignment: NSTextAlignment) {
        currentTextAlignment = alignment
        
        guard editingTextBlock != nil else { return }
        
        let mutableString = richTextContext.attributedString.mutableCopy() as! NSMutableAttributedString
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = alignment
        
        if mutableString.length == 0 {
            applyCurrentStyleToTypingAttributes()
            return
        }
        
        let fullRange = NSRange(location: 0, length: mutableString.length)
        mutableString.addAttribute(.paragraphStyle, value: paragraphStyle, range: fullRange)
        richTextContext.setAttributedString(to: mutableString)
        
        DispatchQueue.main.async {
            self.applyCurrentStyleToTypingAttributes()
            self.saveCurrentEditingBlock()
            self.forceUIUpdate.toggle()
        }
    }
    
    // MARK: - Private Methods
    
    private func applyFontSizeChange() {
        guard editingTextBlock != nil, let textView = findCurrentTextView() else { return }
        
        let selectedRange = textView.selectedRange
        
        if selectedRange.length > 0 {
            applyFontSizeToSelectedText(selectedRange)
        } else {
            applyCurrentStyleToTypingAttributes()
        }
        
        DispatchQueue.main.async {
            self.saveCurrentEditingBlock()
            self.forceUIUpdate.toggle()
        }
    }
    
    private func applyFontFamilyChange() {
        guard editingTextBlock != nil, let textView = findCurrentTextView() else { return }
        
        let selectedRange = textView.selectedRange
        
        if selectedRange.length > 0 {
            applyFontFamilyToSelectedText(selectedRange)
        } else {
            applyCurrentStyleToTypingAttributes()
        }
        
        DispatchQueue.main.async {
            self.saveCurrentEditingBlock()
            self.forceUIUpdate.toggle()
        }
    }
    
    private func applyUnderlineChange() {
        guard editingTextBlock != nil, let textView = findCurrentTextView() else { return }
        
        let selectedRange = textView.selectedRange
        
        if selectedRange.length > 0 {
            applyUnderlineToSelectedText(selectedRange)
        } else {
            applyCurrentStyleToTypingAttributes()
        }
        
        DispatchQueue.main.async {
            self.saveCurrentEditingBlock()
            self.forceUIUpdate.toggle()
        }
    }
    
    private func applyStrikethroughChange() {
        guard editingTextBlock != nil, let textView = findCurrentTextView() else { return }
        
        let selectedRange = textView.selectedRange
        
        if selectedRange.length > 0 {
            applyStrikethroughToSelectedText(selectedRange)
        } else {
            applyCurrentStyleToTypingAttributes()
        }
        
        DispatchQueue.main.async {
            self.saveCurrentEditingBlock()
            self.forceUIUpdate.toggle()
        }
    }
    
    private func applyFontSizeToSelectedText(_ range: NSRange) {
        let mutableString = richTextContext.attributedString.mutableCopy() as! NSMutableAttributedString
        
        mutableString.enumerateAttribute(.font, in: range, options: []) { fontAttribute, subRange, _ in
            if let existingFont = fontAttribute as? UIFont {
                if let newFont = UIFont(name: existingFont.fontName, size: currentFontSize) {
                    mutableString.addAttribute(.font, value: newFont, range: subRange)
                }
            } else {
                if let newFont = UIFont(name: currentFontName, size: currentFontSize) {
                    mutableString.addAttribute(.font, value: newFont, range: subRange)
                }
            }
        }
        
        richTextContext.setAttributedString(to: mutableString)
    }
    
    private func applyFontFamilyToSelectedText(_ range: NSRange) {
        let mutableString = richTextContext.attributedString.mutableCopy() as! NSMutableAttributedString
        
        mutableString.enumerateAttribute(.font, in: range, options: []) { fontAttribute, subRange, _ in
            let fontSize: CGFloat
            if let existingFont = fontAttribute as? UIFont {
                fontSize = existingFont.pointSize
            } else {
                fontSize = currentFontSize
            }
            
            if let newFont = UIFont(name: currentFontName, size: fontSize) {
                mutableString.addAttribute(.font, value: newFont, range: subRange)
            }
        }
        
        richTextContext.setAttributedString(to: mutableString)
    }
    
    private func applyUnderlineToSelectedText(_ range: NSRange) {
        let mutableString = richTextContext.attributedString.mutableCopy() as! NSMutableAttributedString
        
        if currentIsUnderlined {
            mutableString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
        } else {
            mutableString.removeAttribute(.underlineStyle, range: range)
        }
        
        richTextContext.setAttributedString(to: mutableString)
    }
    
    private func applyStrikethroughToSelectedText(_ range: NSRange) {
        let mutableString = richTextContext.attributedString.mutableCopy() as! NSMutableAttributedString
        
        if currentIsStrikethrough {
            mutableString.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: range)
        } else {
            mutableString.removeAttribute(.strikethroughStyle, range: range)
        }
        
        richTextContext.setAttributedString(to: mutableString)
    }
    
    private func createCurrentStyleAttributes() -> [NSAttributedString.Key: Any] {
        var attributes: [NSAttributedString.Key: Any] = [:]
        
        // 폰트
        if let font = UIFont(name: currentFontName, size: currentFontSize) {
            attributes[.font] = font
        } else {
            attributes[.font] = UIFont.systemFont(ofSize: currentFontSize)
        }
        
        // 정렬
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = currentTextAlignment
        attributes[.paragraphStyle] = paragraphStyle
        
        // 밑줄
        if currentIsUnderlined {
            attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
        }
        
        // 취소선
        if currentIsStrikethrough {
            attributes[.strikethroughStyle] = NSUnderlineStyle.single.rawValue
        }
        
        // 기본 색상
        attributes[.foregroundColor] = UIColor.label
        
        return attributes
    }
    
    private func applyCurrentStyleToTypingAttributes() {
        guard let textView = findCurrentTextView() else { return }
        
        let selectedRange = textView.selectedRange
        if selectedRange.length > 0 { return }
        
        let attributes = createCurrentStyleAttributes()
        textView.typingAttributes = attributes
        
        // 한글 IME 대응
        for delay in [0.01, 0.02, 0.05] {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                if textView.selectedRange.length == 0 {
                    textView.typingAttributes = attributes
                }
            }
        }
        
        richTextContext.fontSize = currentFontSize
    }
    
    // 텍스트 변경 후 커서 위치 스타일 동기화
    func handleTextChange(isDeleteOperation: Bool = false) {
        guard !isApplyingStyle else { return }
        
        if isDeleteOperation {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                self.syncStyleFromCurrentPosition()
            }
        }
    }
    
    // 커서 이동 시 스타일 동기화
    func handleCursorPositionChange() {
        guard !isApplyingStyle else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            self.syncStyleFromCurrentPosition()
        }
    }
    
    private func syncStyleFromCurrentPosition() {
        guard let textView = findCurrentTextView() else { return }
        
        let selectedRange = textView.selectedRange
        if selectedRange.length > 0 { return }
        
        guard let attributedText = textView.attributedText else { return }
        let cursorPosition = selectedRange.location
        
        if attributedText.length > 0 && cursorPosition > 0 {
            let checkPosition = min(cursorPosition - 1, attributedText.length - 1)
            let attributes = attributedText.attributes(at: checkPosition, effectiveRange: nil)
            
            // 폰트 동기화
            if let font = attributes[.font] as? UIFont {
                currentFontSize = font.pointSize
                currentFontName = font.fontName
            }
            
            // 정렬 동기화
            if let paragraphStyle = attributes[.paragraphStyle] as? NSParagraphStyle {
                currentTextAlignment = paragraphStyle.alignment
            }
            
            // 밑줄 동기화
            if let underlineStyle = attributes[.underlineStyle] as? Int {
                currentIsUnderlined = underlineStyle != 0
            } else {
                currentIsUnderlined = false
            }
            
            // 취소선 동기화
            if let strikethroughStyle = attributes[.strikethroughStyle] as? Int {
                currentIsStrikethrough = strikethroughStyle != 0
            } else {
                currentIsStrikethrough = false
            }
            
            // UI 업데이트
            DispatchQueue.main.async {
                self.forceUIUpdate.toggle()
            }
        }
        
        lastCursorPosition = cursorPosition
    }
    
    // MARK: - Getters
    
    func getCurrentFontSize() -> CGFloat { currentFontSize }
    func getCurrentFontName() -> String { currentFontName }
    func getCurrentIsUnderlined() -> Bool { currentIsUnderlined }
    func getCurrentIsStrikethrough() -> Bool { currentIsStrikethrough }
    
    func getCurrentTextAlignment() -> NSTextAlignment {
        let attributedString = richTextContext.attributedString
        guard attributedString.length > 0 else { return currentTextAlignment }
        
        if let paragraphStyle = attributedString.attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSParagraphStyle {
            return paragraphStyle.alignment
        }
        
        return currentTextAlignment
    }
    
    // MARK: - Helper Methods
    
    private func findCurrentTextView() -> UITextView? {
        let scenes = UIApplication.shared.connectedScenes
        for scene in scenes {
            if let windowScene = scene as? UIWindowScene {
                for window in windowScene.windows {
                    if let textView = findTextViewInView(window) {
                        return textView
                    }
                }
            }
        }
        return nil
    }

    private func findTextViewInView(_ view: UIView) -> UITextView? {
        if let textView = view as? UITextView, textView.isFirstResponder {
            return textView
        }
        
        for subview in view.subviews {
            if let textView = findTextViewInView(subview) {
                return textView
            }
        }
        
        return nil
    }
    
    // MARK: - Drawing
    
    func loadSavedDrawing(diaryId: Int) {
        do {
            let result = try DrawingStore.load(diaryId: diaryId)
            self.savedDrawing = result.drawing
            self.drawingOffsetY = result.offsetY
        } catch {
            // 파일이 없거나 실패하면 그냥 표시 안 함
            self.savedDrawing = nil
            self.drawingOffsetY = 0
        }
    }
    
    func commitDrawingFromCanvas(_ drawing: PKDrawing, offsetY: CGFloat, autosave: Bool = false) {
        self.savedDrawing = drawing
        self.drawingOffsetY = offsetY
        markDirty()
        if autosave, canSave { // 이미지 임시URL 등 조건 충족 시에만 즉시 저장
            manualSave()
        }
    }
}
