//  DiaryMainView.swift
//  Divary
//
//  Created by 김나영 on 7/6/25.

import SwiftUI
import PhotosUI
import RichTextKit

enum DiaryFooterBarType {
    case main, textStyle, fontSize, alignment, fontFamily
}

struct DiaryMainView: View {
    @StateObject private var viewModel = DiaryMainViewModel()
    @FocusState private var isRichTextEditorFocused: Bool
    @State private var footerBarType: DiaryFooterBarType = .main
    
    private var activeFooterBar: some View {
        switch footerBarType {
        case .main: return AnyView(footerBar())
        case .textStyle: return AnyView(TextfooterBar())
        case .fontSize: return AnyView(FontSizeFooterBar())
        case .alignment: return AnyView(FontalignmentFooterBar())
        case .fontFamily: return AnyView(FontFamilyFooterBar())
        }
    }
    
    var body: some View {
        diaryMain
        activeFooterBar
    }
    
    private var diaryMain: some View {
        ScrollView(.vertical, showsIndicators: false) {
            ZStack {
                GeometryReader { geometry in
                          Image("gridBackground")
                              .resizable(resizingMode: .tile)
                              .scaledToFill()
                              .frame(
                                  width: geometry.size.width,
                                  height: max(geometry.size.height, UIScreen.main.bounds.height)
                              )
                      }.ignoresSafeArea()
                
                VStack(spacing: 8) {
                    ForEach(viewModel.blocks) { block in
                        switch block.content {
                        case .text(let content):
                            if viewModel.editingTextBlock?.id == block.id {
                                editingTextBlockView(content: content)
                            } else {
                                // AttributedTextView 대신 커스텀 텍스트 뷰 사용
                                CustomAttributedTextView(attributedText: content.text)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .frame(maxWidth: .infinity)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 4)
                                    .background(Color.clear)
                                    .onTapGesture {
                                        viewModel.startEditing(block)
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                            isRichTextEditorFocused = true
                                        }
                                    }
                            }
                            
                        case .image(let image):
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .padding()
                        }
                    }
                    
                    Spacer(minLength: 100)
                }
            }
            .onChange(of: viewModel.selectedItems) { _, newItems in
                for item in newItems {
                    Task {
                        if let data = try? await item.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data) {
                            await MainActor.run {
                                viewModel.addImage(uiImage)
                            }
                        }
                    }
                }
                viewModel.selectedItems.removeAll()
            }
        }
    }

    // 커스텀 AttributedTextView 구현
    struct CustomAttributedTextView: UIViewRepresentable {
        let attributedText: NSAttributedString
        
        func makeUIView(context: Context) -> UITextView {
            let textView = UITextView()
            textView.backgroundColor = UIColor.clear
            textView.isEditable = false
            textView.isSelectable = false
            textView.isScrollEnabled = false
            textView.textContainer.lineFragmentPadding = 0
            textView.textContainerInset = UIEdgeInsets.zero
            textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            textView.setContentHuggingPriority(.defaultHigh, for: .vertical)
            return textView
        }
        
        func updateUIView(_ uiView: UITextView, context: Context) {
            // AttributedString의 정렬을 포함한 모든 속성을 그대로 적용
            uiView.attributedText = attributedText
            
            // 텍스트 변경 후 크기 재계산
            DispatchQueue.main.async {
                uiView.invalidateIntrinsicContentSize()
            }
        }
    }

    // editingTextBlockView의 text Binding도 수정
    private func editingTextBlockView(content: RichTextContent) -> some View {
        RichTextEditor(
            text: Binding(
                get: {
                    viewModel.richTextContext.attributedString
                },
                set: { newValue in
                    viewModel.richTextContext.setAttributedString(to: newValue)
                    
                    // 텍스트 변경시 즉시 저장 및 정렬 상태 업데이트
                    DispatchQueue.main.async {
                        
                        // 정렬 상태 즉시 동기화
                        viewModel.currentTextAlignment = viewModel.getCurrentTextAlignment()
                    }
                }
            ),
            context: viewModel.richTextContext
        )
        .focusedValue(\.richTextContext, viewModel.richTextContext)
        .focused($isRichTextEditorFocused)
        .frame(minHeight: 80)
        .fixedSize(horizontal: false, vertical: true)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.clear)
        .onAppear {
            DispatchQueue.main.async {
                UITextView.appearance().backgroundColor = UIColor.clear
                UITextView.appearance().textContainer.lineFragmentPadding = 0
                UITextView.appearance().textContainerInset = UIEdgeInsets.zero
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isRichTextEditorFocused = true
                // 정렬 상태 즉시 동기화
                viewModel.currentTextAlignment = viewModel.getCurrentTextAlignment()
            }
        }
        // 정렬 상태 변경 시 RichTextEditor 강제 새로고침
        .onChange(of: viewModel.currentTextAlignment) { _, newAlignment in
            // RichTextEditor가 활성화된 상태에서 정렬 변경을 즉시 반영
            DispatchQueue.main.async {
                let currentText = viewModel.richTextContext.attributedString
                
                let mutableString = currentText.mutableCopy() as! NSMutableAttributedString
                
                if mutableString.length > 0 {
                    let paragraphStyle = NSMutableParagraphStyle()
                    paragraphStyle.alignment = newAlignment
                    
                    // 기존 스타일 보존
                    if let existingStyle = mutableString.attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSParagraphStyle {
                        paragraphStyle.lineSpacing = existingStyle.lineSpacing
                        paragraphStyle.paragraphSpacing = existingStyle.paragraphSpacing
                        paragraphStyle.headIndent = existingStyle.headIndent
                        paragraphStyle.tailIndent = existingStyle.tailIndent
                        paragraphStyle.firstLineHeadIndent = existingStyle.firstLineHeadIndent
                        paragraphStyle.minimumLineHeight = existingStyle.minimumLineHeight
                        paragraphStyle.maximumLineHeight = existingStyle.maximumLineHeight
                        paragraphStyle.lineBreakMode = existingStyle.lineBreakMode
                        paragraphStyle.baseWritingDirection = existingStyle.baseWritingDirection
                    }
                    
                    let fullRange = NSRange(location: 0, length: mutableString.length)
                    mutableString.addAttribute(.paragraphStyle, value: paragraphStyle, range: fullRange)
                    
                    // RichTextContext에 강제로 새로운 attributedString 설정
                    viewModel.richTextContext.setAttributedString(to: mutableString)
                }
                
                viewModel.objectWillChange.send()
            }
        }
        .onChange(of: viewModel.getCurrentFontName()) { _, _ in
            // 폰트 변경시 강제 저장
            DispatchQueue.main.async {
                viewModel.saveCurrentEditingBlock()
            }
        }
        .onChange(of: viewModel.getCurrentFontSize()) { _, _ in
            // 폰트 사이즈 변경시 강제 저장
            DispatchQueue.main.async {
                viewModel.saveCurrentEditingBlock()
            }
        }
        // 강제 업데이트 감지
        .onChange(of: viewModel.forceUIUpdate) { _, _ in
            DispatchQueue.main.async {
                viewModel.objectWillChange.send()
            }
        }
    }
    
    // MARK: - Footer Bars
    
    @ViewBuilder
    private func footerBar() -> some View {
        HStack(spacing: 20) {
            PhotosPicker(selection: $viewModel.selectedItems, matching: .images) {
                Image(.photo)
            }
            Button(action: { footerBarType = .textStyle }) {
                Image(.font)
            }
            Button(action: { footerBarType = .alignment }) {
                Image(.alignText)
            }
            Button(action: {}) { Image(.sticker) }
            Button(action: {}) { Image(.pencil) }
            
            Spacer()
            
            if viewModel.editingTextBlock == nil {
                Button(action: {
                    viewModel.addTextBlock()
                    isRichTextEditorFocused = true
                    
                }) {
                    Image(.keyboard1)
                }
            } else {
                Button(action: {
                    // 편집 완료 전에 현재 정렬 상태를 강제로 적용
                    viewModel.saveCurrentEditingBlock()
                    viewModel.commitEditingTextBlock()
                    isRichTextEditorFocused = false
                    footerBarType = .main
                }) {
                    Image(.keyboard)
                }
            }
        }
        .foregroundStyle(Color(.bWBlack))
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color(.G_100))
    }
    
    // MARK: - TextfooterBar
    @ViewBuilder
    private func TextfooterBar() -> some View {
        HStack(spacing: 20) {
            Button(action: { footerBarType = .main }) {
                Image(.iconamoonCloseThin)
            }
            Button(action: {footerBarType = .fontFamily}) { //폰트 변경
                Image("mingcute_font-size-line")
            }
            Button(action: { footerBarType = .fontSize }) {
                Text("\(Int(viewModel.richTextContext.fontSize))")
                    .font(Font.NanumSquareNeo.NanumSquareNeoBold(size: 18))
            }
            Button(action: {
                viewModel.toggleStyle(.underlined)
            }) {
                Image("humbleicons_underline")
                    .foregroundStyle(viewModel.richTextContext.hasStyle(.underlined) ?
                                     Color.primary_sea_blue : Color.bw_black)
            }
            .cornerRadius(6)
            
            Button(action: {
                viewModel.toggleStyle(.strikethrough)
            }) {
                Image("mi_strikethrough")
                    .foregroundStyle(viewModel.richTextContext.hasStyle(.strikethrough) ?
                                     Color.primary_sea_blue : Color.bw_black)
            }
            .cornerRadius(6)
            
            Button(action: {
                viewModel.toggleStyle(.strikethrough)
            }) {
                Image("humbleicons_italic")
                    .foregroundStyle(viewModel.isCustomItalicApplied() ?
                                     Color.primary_sea_blue : Color.bw_black)
            }
            .cornerRadius(6)
            
            Spacer()
        }
        .foregroundStyle(Color(.bWBlack))
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color(.G_100))
        // UI 강제 업데이트를 위한 더미 의존성
        .onChange(of: viewModel.forceUIUpdate) { _, _ in
            // 더미 변수 변경시 UI 재구성
        }
        // RichTextContext 변경 감지
        .onChange(of: viewModel.richTextContext.attributedString) { _, _ in
            // AttributedString 변경시 UI 재구성
        }
    }
    
    // MARK: - FontSizeFooterBar
    @ViewBuilder
    private func FontSizeFooterBar() -> some View {
        HStack(spacing: 20) {
            Button(action: { footerBarType = .textStyle }) {
                Image(.iconamoonCloseThin)
            }
            ForEach([12, 14, 16, 18, 20, 24], id: \.self) { size in
                Button(action: {
                    viewModel.setFontSize(CGFloat(size))
                }) {
                    Text("\(size)")
                        .font(.system(size: 18))
                        .foregroundStyle(Int(viewModel.getCurrentFontSize()) == size ?  // 변경!
                                         Color.primary_sea_blue : Color.bw_black)
                }
                .cornerRadius(6)
            }
            Spacer()
        }
        .foregroundStyle(Color(.bWBlack))
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color(.G_100))
        .onChange(of: viewModel.forceUIUpdate) { _, _ in  // 변경!
            // forceUIUpdate 감지로 UI 재구성
        }
    }
    
    // MARK: - FontalignmentFooterBar
    @ViewBuilder
    private func FontalignmentFooterBar() -> some View {
        HStack(spacing: 20) {
            Button(action: { footerBarType = .main }) {
                Image(.iconamoonCloseThin)
            }
            
            // 왼쪽 정렬
            Button(action: {
                viewModel.setTextAlignment(.left)
            }) {
                Image(.alignTextLeading)
                    .foregroundColor(viewModel.currentTextAlignment == .left ? Color.primary_sea_blue : Color.bw_black)
            }
            .background(
                viewModel.currentTextAlignment == .left ?
                Color.blue.opacity(0.2) : Color.clear
            )
            .cornerRadius(6)
            
            // 가운데 정렬
            Button(action: {
                viewModel.setTextAlignment(.center)
            }) {
                Image(.alignTextCenter)
                    .foregroundColor(viewModel.currentTextAlignment == .center ? Color.primary_sea_blue : Color.bw_black)
            }
            .background(
                viewModel.currentTextAlignment == .center ?
                Color.blue.opacity(0.2) : Color.clear
            )
            .cornerRadius(6)
            
            // 오른쪽 정렬
            Button(action: {
                viewModel.setTextAlignment(.right)
            }) {
                Image(.alignTextTrailing)
                    .foregroundColor(viewModel.currentTextAlignment == .right ? Color.primary_sea_blue : Color.bw_black)
            }
            .background(
                viewModel.currentTextAlignment == .right ?
                Color.blue.opacity(0.2) : Color.clear
            )
            .cornerRadius(6)
            
            Spacer()
        }
        .foregroundStyle(Color(.bWBlack))
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color(.G_100))
        // 여러 상태 변경 감지
        .onChange(of: viewModel.currentTextAlignment) { _, _ in
            // 텍스트 정렬 변경시 UI 재구성
        }
        .onChange(of: viewModel.forceUIUpdate) { _, _ in
            // 강제 업데이트시 UI 재구성
        }
        .onChange(of: viewModel.richTextContext.attributedString) { _, _ in
            // AttributedString 변경시 정렬 상태 동기화
            DispatchQueue.main.async {
                viewModel.currentTextAlignment = viewModel.getCurrentTextAlignment()
            }
        }
    }
    
    // MARK: - FontFamilyFooterBar
    @ViewBuilder
    private func FontFamilyFooterBar() -> some View {
        VStack(spacing: 0) {
            // 상단 헤더
            HStack {
                Button(action: { footerBarType = .textStyle }) {
                    Image(.chevronLeft)
                        .foregroundStyle(Color(.bWBlack))
                }
                
                Spacer()
                
                Text("글씨체")
                    .font(Font.NanumSquareNeo.NanumSquareNeoBold(size: 18))
                    .foregroundStyle(Color(.bWBlack))
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color(.G_100))
            
            // 글씨체 목록 - 안전한 폰트들만 사용
            VStack(spacing: 0) {
                FontOptionRow(
                    title: "기본 글씨체",
                    font: Font.NanumSquareNeo.NanumSquareNeoBold(size: 16),
                    fontName: "NanumSquareNeoTTF-cBd",
                    isSelected: viewModel.getCurrentFontName() == "NanumSquareNeoTTF-cBd",
                    action: { viewModel.setFontFamily("NanumSquareNeoTTF-cBd") }
                )
                
                FontOptionRow(
                    title: "옴뮤 예쁜체",
                    font: Font.omyu.regular(size: 16),
                    fontName: "omyu_pretty",
                    isSelected: viewModel.getCurrentFontName() == "omyu_pretty",
                    action: { viewModel.setFontFamily("omyu_pretty") }
                )
            
                
                // 온글잎 김콩해 - 안전한 처리
                FontOptionRow(
                    title: "온글잎 김콩해",
                    font: Font.OwnglyphKonghae.konghaeRegular(size: 16),
                    fontName: "Ownglyph_konghae-Rg",
                    isSelected: viewModel.getCurrentFontName() == "Ownglyph_konghae-Rg",
                    action: { viewModel.setFontFamily("Ownglyph_konghae-Rg") }
                )
                
                // 카페24 고운밤 - 안전한 처리
                FontOptionRow(
                    title: "카페24 고운밤",
                    font: Font.Cafe24Oneprettynight.Cafe24OneprettynightRegular(size: 16),
                    fontName: "Cafe24Oneprettynight",
                    isSelected: viewModel.getCurrentFontName() == "Cafe24Oneprettynight",
                    action: { viewModel.setFontFamily("Cafe24Oneprettynight") }
                )
                
                // 나눔 한윤체 - 안전한 처리
                FontOptionRow(
                    title: "나눔 한윤체",
                    font: Font.NanumHanYunCe.NanumHanYunCeRegular(size: 16),
                    fontName: "NanumHanYunCe",
                    isSelected: viewModel.getCurrentFontName() == "NanumHanYunCe",
                    action: { viewModel.setFontFamily("NanumHanYunCe") }
                )

            }
            .background(Color(.G_100))
        }
    }
}

#Preview {
    DiaryMainView()
}
