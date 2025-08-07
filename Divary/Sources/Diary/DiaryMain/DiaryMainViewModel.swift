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

@Observable
class DiaryMainViewModel {
    var blocks: [DiaryBlock] = []
    var selectedItems: [PhotosPickerItem] = []
    var editingTextBlock: DiaryBlock? = nil
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
    
    // MARK: - 사진 날짜 가져오기
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
            print("extractPhotoDate error: \(error)")
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
    }

    func saveCurrentEditingBlock() {
        guard let block = editingTextBlock,
              case .text(let content) = block.content else { return }

        let newText = richTextContext.attributedString
        if !content.text.isEqual(to: newText) {
            content.text = newText
            content.context = richTextContext
        }
    }

    func commitEditingTextBlock() {
        saveCurrentEditingBlock()
        editingTextBlock = nil
    }

//    func addImage(_ image: FramedImageDTO) {
//        let block = DiaryBlock(content: .image(image))
//        blocks.append(block)
//    }
    func addImages(_ images: [FramedImageDTO]) {
        images.forEach { image in
            let block = DiaryBlock(content: .image(image))
            blocks.append(block)
        }
    }

    
    func startEditing(_ block: DiaryBlock) {
        if case .text(let content) = block.content {
            editingTextBlock = block
            richTextContext = content.context
            content.context.setAttributedString(to: content.text)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.syncStyleFromCurrentPosition()
                self.forceUIUpdate.toggle()
            }
        }
    }

    func deleteBlock(_ block: DiaryBlock) {
        blocks.removeAll { $0.id == block.id }
        if editingTextBlock?.id == block.id {
            editingTextBlock = nil
        }
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
    
    func loadSavedDrawing() {
        guard let data = UserDefaults.standard.data(forKey: "SavedDrawingMeta"),
              let meta = try? JSONDecoder().decode(DrawingContentDTO.self, from: data),
              let drawingData = Data(base64Encoded: meta.base64),
              let drawing = try? PKDrawing(data: drawingData) else {
            return
        }
        self.savedDrawing = drawing
        self.drawingOffsetY = meta.offsetY
//        print("drawingOffsetY = \(drawingOffsetY)")
//        print("meta.offsetY = \(meta.offsetY)")
    }
}
