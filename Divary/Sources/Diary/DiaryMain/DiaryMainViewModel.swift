//
//  DiaryMainViewModel.swift
//  Divary
//

import SwiftUI
import PhotosUI
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
    
    // 폰트 상태 추적을 위한 변수들 - 실제 적용 가능한 폰트로 초기화
    var currentFontSize: CGFloat = 16.0
    var currentFontName: String = "NanumSquareNeoTTF-cBd"
    
    var savedDrawing: PKDrawing? = nil
    var drawingOffsetY: CGFloat = 0

    // MARK: - Block Management
    
    func addTextBlock() {
        // 빈 텍스트로 시작
        let text = NSAttributedString(string: "")
        let content = RichTextContent(text: text)
        let block = DiaryBlock(content: .text(content))
        blocks.append(block)
        
        editingTextBlock = block
        richTextContext = content.context
        richTextContext.setAttributedString(to: text)
        
        // RichTextContext의 fontSize 설정
        richTextContext.fontSize = currentFontSize
    }

    func saveCurrentEditingBlock() {
        guard let block = editingTextBlock,
              case .text(let content) = block.content else { return }

        let newText = richTextContext.attributedString
        
        // 텍스트가 실제로 변경된 경우에만 업데이트
        if !content.text.isEqual(to: newText) {
            content.text = newText
            content.context = richTextContext
            content.context.setAttributedString(to: newText)
        }
    }

    func commitEditingTextBlock() {
        saveCurrentEditingBlock()
        editingTextBlock = nil
    }

    func addImage(_ image: UIImage) {
        let block = DiaryBlock(content: .image(image))
        blocks.append(block)
    }

    func startEditing(_ block: DiaryBlock) {
        if case .text(let content) = block.content {
            editingTextBlock = block
            richTextContext = content.context
            content.context.setAttributedString(to: content.text)
            
            // 편집 시작할 때는 상태 변수 변경하지 않음 - 현재 설정 유지
            forceUIUpdate.toggle()
        }
    }

    func deleteBlock(_ block: DiaryBlock) {
        blocks.removeAll { $0.id == block.id }
        if editingTextBlock?.id == block.id {
            editingTextBlock = nil
        }
    }

    // MARK: - Text Styling
    
    func toggleStyle(_ style: RichTextStyle) {
        guard editingTextBlock != nil else { return }
        
        let currentSelectedRange = richTextContext.selectedRange
        let attributedString = richTextContext.attributedString
        
        guard attributedString.length > 0 else { return }
        
        if currentSelectedRange.location == NSNotFound || currentSelectedRange.length == 0 {
            let fullRange = NSRange(location: 0, length: attributedString.length)
            richTextContext.handle(.selectRange(fullRange))
            richTextContext.toggleStyle(style)
            richTextContext.handle(.selectRange(currentSelectedRange))
        } else {
            richTextContext.toggleStyle(style)
        }
        
        DispatchQueue.main.async {
            self.saveCurrentEditingBlock()
            self.forceUIUpdate.toggle()
        }
    }

    // MARK: - Font Management
    
    func setFontSize(_ size: CGFloat) {
        guard editingTextBlock != nil else { return }
        
        // 상태 먼저 업데이트
        currentFontSize = size
        
        let mutableString = richTextContext.attributedString.mutableCopy() as! NSMutableAttributedString
        
        // 텍스트가 없으면 컨텍스트만 업데이트
        guard mutableString.length > 0 else {
            richTextContext.fontSize = size
            return
        }
        
        let selectedRange = getSelectedRange(for: mutableString)
        
        // 전체 범위에 현재 설정된 폰트 적용
        if let font = UIFont(name: currentFontName, size: size) {
            mutableString.addAttribute(.font, value: font, range: selectedRange)
        } else {
            // 폰트 생성 실패 시 시스템 폰트로 대체
            let systemFont = UIFont.systemFont(ofSize: size)
            mutableString.addAttribute(.font, value: systemFont, range: selectedRange)
        }
        
        // 핵심: richTextContext를 완전히 동기화
        richTextContext.setAttributedString(to: mutableString)
        richTextContext.fontSize = size
        
        // RichTextContext의 내부 상태 강제 동기화
        DispatchQueue.main.async {
            let currentRange = self.richTextContext.selectedRange
            self.richTextContext.handle(.selectRange(NSRange(location: 0, length: 0)))
            
            DispatchQueue.main.async {
                self.richTextContext.handle(.selectRange(currentRange))
                self.saveCurrentEditingBlock()
                self.forceUIUpdate.toggle()
            }
        }
    }
    
    func getCurrentFontSize() -> CGFloat {
        return currentFontSize
    }

    func getCurrentFontName() -> String {
        return currentFontName
    }

    func setFontFamily(_ fontName: String) {
        guard editingTextBlock != nil else { return }
        
        // 상태 먼저 업데이트
        currentFontName = fontName
        
        let mutableString = richTextContext.attributedString.mutableCopy() as! NSMutableAttributedString
        
        // 텍스트가 없으면 상태만 업데이트
        guard mutableString.length > 0 else {
            return
        }
        
        let selectedRange = getSelectedRange(for: mutableString)
        
        // 현재 상태의 폰트 크기로 새 폰트 생성
        if let font = UIFont(name: fontName, size: currentFontSize) {
            mutableString.addAttribute(.font, value: font, range: selectedRange)
        } else {
            // 폰트 생성 실패 시 상태 되돌리기
            return
        }
        
        // 핵심: richTextContext를 완전히 동기화
        richTextContext.setAttributedString(to: mutableString)
        
        // RichTextContext의 내부 상태 강제 동기화
        DispatchQueue.main.async {
            let currentRange = self.richTextContext.selectedRange
            self.richTextContext.handle(.selectRange(NSRange(location: 0, length: 0)))
            
            DispatchQueue.main.async {
                self.richTextContext.handle(.selectRange(currentRange))
                self.saveCurrentEditingBlock()
                self.forceUIUpdate.toggle()
            }
        }
    }

    // MARK: - Text Alignment
    
    func setTextAlignment(_ alignment: NSTextAlignment) {
        guard editingTextBlock != nil else { return }
        
        let mutableString = richTextContext.attributedString.mutableCopy() as! NSMutableAttributedString
        guard mutableString.length > 0 else {
            currentTextAlignment = alignment
            return
        }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = alignment
        
        let fullRange = NSRange(location: 0, length: mutableString.length)
        mutableString.addAttribute(.paragraphStyle, value: paragraphStyle, range: fullRange)
        
        // 핵심: richTextContext를 완전히 동기화
        richTextContext.setAttributedString(to: mutableString)
        currentTextAlignment = alignment
        
        // RichTextContext의 내부 상태 강제 동기화
        DispatchQueue.main.async {
            let currentRange = self.richTextContext.selectedRange
            self.richTextContext.handle(.selectRange(NSRange(location: 0, length: 0)))
            
            DispatchQueue.main.async {
                self.richTextContext.handle(.selectRange(currentRange))
                self.saveCurrentEditingBlock()
                self.forceUIUpdate.toggle()
            }
        }
    }
     
    func getCurrentTextAlignment() -> NSTextAlignment {
        let attributedString = richTextContext.attributedString
        guard attributedString.length > 0 else { return .left }
        
        if let paragraphStyle = attributedString.attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSParagraphStyle {
            return paragraphStyle.alignment
        }
        
        return .left
    }

    // MARK: - Helper
    
    private func getSelectedRange(for mutableString: NSMutableAttributedString) -> NSRange {
        let range = richTextContext.selectedRange
        let isValidRange = range.location != NSNotFound &&
                           range.location >= 0 &&
                           range.location < mutableString.length &&
                           NSMaxRange(range) <= mutableString.length

        if isValidRange && range.length > 0 {
            return range
        } else {
            return NSRange(location: 0, length: mutableString.length)
        }
    }
    
    // MARK: - Drawing
    
    func loadSavedDrawing() {
        guard let data = UserDefaults.standard.data(forKey: "SavedDrawingMeta"),
              let meta = try? JSONDecoder().decode(DrawingMeta.self, from: data),
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
