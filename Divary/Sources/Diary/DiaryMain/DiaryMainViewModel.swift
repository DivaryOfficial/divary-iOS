//
//  DiaryMainViewModel.swift
//  Divary
//


import SwiftUI
import PhotosUI
import RichTextKit

class DiaryMainViewModel: ObservableObject {
    @Published var blocks: [DiaryBlock] = []
    @Published var selectedItems: [PhotosPickerItem] = []
    @Published var editingTextBlock: DiaryBlock? = nil
    @Published var richTextContext = RichTextContext()
    
    // UI 강제 업데이트용 더미 변수
    @Published var forceUIUpdate: Bool = false
    // 현재 텍스트 정렬 상태를 추적하는 변수 추가
    @Published var currentTextAlignment: NSTextAlignment = .left

    // 새 텍스트 블록 추가
    func addTextBlock() {
        let text = NSAttributedString(string: "")
        let content = RichTextContent(text: text)
        let block = DiaryBlock(content: .text(content))
        blocks.append(block)
        
        editingTextBlock = block
        richTextContext = content.context
    }

    // 실시간으로 편집 중인 텍스트 블록 저장
    func saveCurrentEditingBlock() {
        guard let block = editingTextBlock,
              case .text(let content) = block.content else { return }

        let newText = richTextContext.attributedString
        let isTextChanged = content.text != newText

        if isTextChanged {
            content.text = newText
            content.context = richTextContext
            content.context.setAttributedString(to: newText)
        }

        // 강제 트리거 (첫 글자가 아닐 때만 실행)
        let isFirstCharacter = newText.length == 1
        let shouldTrigger = (richTextContext.selectedRange.length == 0 || richTextContext.selectedRange.location == NSNotFound) && !isFirstCharacter
        
        if shouldTrigger {
            let originalCursor = richTextContext.selectedRange
            
            // 임시로 맨 앞 트리거
            richTextContext.handle(.selectRange(NSRange(location: 0, length: 0)))
            
            // 즉시 원래 커서 위치로 복원
            DispatchQueue.main.async {
                if originalCursor.location != NSNotFound {
                    let safePosition = min(originalCursor.location, newText.length)
                    self.richTextContext.handle(.selectRange(NSRange(location: safePosition, length: 0)))
                } else {
                    self.richTextContext.handle(.selectRange(NSRange(location: newText.length, length: 0)))
                }
            }
        }
    }
    
    // UI 강제 업데이트
    private func forceUpdateUI() {
        DispatchQueue.main.async {
            self.forceUIUpdate.toggle()
        }
    }

    // 편집 중인 텍스트 블록 커밋
    func commitEditingTextBlock() {
        saveCurrentEditingBlock()
        editingTextBlock = nil
    }

    // 이미지 추가
    func addImage(_ image: UIImage) {
        let block = DiaryBlock(content: .image(image))
        blocks.append(block)
    }

    // 현재 편집 중 블록에 스타일 토글 + 실시간 저장 + UI 업데이트
        func toggleStyle(_ style: RichTextStyle) {
            guard editingTextBlock != nil else { return }
            
            let currentSelectedRange = richTextContext.selectedRange
            let attributedString = richTextContext.attributedString
            
            // 텍스트가 없으면 아무것도 하지 않음
            guard attributedString.length > 0 else { return }
            
            // 선택 영역이 없거나 길이가 0이면 전체에 적용
            if currentSelectedRange.location == NSNotFound || currentSelectedRange.length == 0 {
                // 전체 텍스트를 임시로 선택한 상태로 만들어서 스타일 적용
                let mutableString = attributedString.mutableCopy() as! NSMutableAttributedString
                let fullRange = NSRange(location: 0, length: mutableString.length)
                
                // RichTextContext에 전체 선택 상태 임시 설정 후 toggleStyle 사용
                _ = RichTextInsertion<String>.text("", at: fullRange.location, moveCursor: false)
                let action = RichTextAction.selectRange(fullRange)
                richTextContext.handle(action)
                
                // 이제 toggleStyle 적용
                richTextContext.toggleStyle(style)
                
                // 원래 커서 위치로 복원
                let restoreAction = RichTextAction.selectRange(currentSelectedRange)
                richTextContext.handle(restoreAction)
            } else {
                // 선택된 범위가 있으면 기본 RichTextKit 기능 사용
                richTextContext.toggleStyle(style)
            }
            
            // 스타일 변경 후 즉시 저장 및 UI 업데이트
            DispatchQueue.main.async {
                self.saveCurrentEditingBlock()
                self.objectWillChange.send()
            }
        }

    // 선택한 블록을 편집 대상으로 설정
    func startEditing(_ block: DiaryBlock) {
        if case .text(let content) = block.content {
            editingTextBlock = block
            richTextContext = content.context
            content.context.setAttributedString(to: content.text)
            forceUpdateUI()
        }
    }
    
    // 블록 삭제
    func deleteBlock(_ block: DiaryBlock) {
        blocks.removeAll { $0.id == block.id }
        if editingTextBlock?.id == block.id {
            editingTextBlock = nil
        }
    }
    
    // 커스텀 이탤릭 적용 + 실시간 저장 + UI 업데이트
      func applyCustomItalic() {
          guard editingTextBlock != nil else { return }
          
          let mutableString = richTextContext.attributedString.mutableCopy() as! NSMutableAttributedString
          
          guard mutableString.length > 0 else { return }
          
          let selectedRange = getSelectedRange(for: mutableString)
          
          let currentObliqueness = mutableString.attribute(.obliqueness,
                                                         at: selectedRange.location,
                                                         effectiveRange: nil) as? NSNumber ?? 0
          
          if currentObliqueness.floatValue > 0 {
              mutableString.removeAttribute(.obliqueness, range: selectedRange)
          } else {
              mutableString.addAttribute(.obliqueness, value: 0.2, range: selectedRange)
          }
          
          richTextContext.setAttributedString(to: mutableString)
          
          // 이탤릭 적용 후 즉시 저장 및 UI 업데이트
          DispatchQueue.main.async {
              self.saveCurrentEditingBlock()
              self.objectWillChange.send() // ObservableObject 변경 알림
          }
      }
    
    
    func isCustomItalicApplied() -> Bool {
            let attributedString = richTextContext.attributedString
            
            guard attributedString.length > 0 else { return false }
            
            let contextSelectedRange = richTextContext.selectedRange
            let checkLocation: Int
            
            if contextSelectedRange.location != NSNotFound,
               contextSelectedRange.location >= 0,
               contextSelectedRange.location < attributedString.length {
                checkLocation = contextSelectedRange.location
            } else {
                checkLocation = 0
            }
            
            guard checkLocation < attributedString.length else { return false }
            
            if let obliqueness = attributedString.attribute(.obliqueness, at: checkLocation, effectiveRange: nil) as? NSNumber {
                return obliqueness.floatValue > 0
            }
            
            return false
        }

    // 폰트 크기 변경 + 실시간 저장 + UI 업데이트
    func setFontSize(_ size: CGFloat) {
        guard editingTextBlock != nil else { return }
        
        let mutableString = richTextContext.attributedString.mutableCopy() as! NSMutableAttributedString
        guard mutableString.length > 0 else {
            // 텍스트가 없으면 richTextContext의 fontSize만 설정
            richTextContext.fontSize = size
            DispatchQueue.main.async {
                self.saveCurrentEditingBlock()
                self.objectWillChange.send()
            }
            return
        }
        
        // getSelectedRange 헬퍼 메서드 사용 (선택 영역이 없으면 전체 범위 반환)
        let selectedRange = getSelectedRange(for: mutableString)
        
        // 선택된 범위의 각 문자에 대해 폰트 크기 변경
        mutableString.enumerateAttribute(.font, in: selectedRange, options: []) { (value, range, _) in
            if let currentFont = value as? UIFont {
                let newFont = currentFont.withSize(size)
                mutableString.addAttribute(.font, value: newFont, range: range)
            } else {
                // 폰트 속성이 없으면 기본 폰트로 설정
                let defaultFont = UIFont.systemFont(ofSize: size)
                mutableString.addAttribute(.font, value: defaultFont, range: range)
            }
        }
        
        richTextContext.setAttributedString(to: mutableString)
        richTextContext.fontSize = size // context의 fontSize도 업데이트
        
        DispatchQueue.main.async {
            self.saveCurrentEditingBlock()
            self.objectWillChange.send()
        }
    }
    
    // 현재 실제 텍스트의 폰트 사이즈 가져오기
    func getCurrentFontSize() -> CGFloat {
        let attributedString = richTextContext.attributedString
        
        guard attributedString.length > 0 else { return 16.0 } // 기본값
        
        let checkLocation: Int
        let selectedRange = richTextContext.selectedRange
        
        if selectedRange.location != NSNotFound && selectedRange.location < attributedString.length {
            checkLocation = selectedRange.location
        } else {
            checkLocation = 0
        }
        
        if let font = attributedString.attribute(.font, at: checkLocation, effectiveRange: nil) as? UIFont {
            return font.pointSize
        }
        
        return 16.0 // 기본값
    }
    
    // NSTextAlignment를 사용해서 직접 NSAttributedString 조작
     func setTextAlignment(_ alignment: NSTextAlignment) {
         guard editingTextBlock != nil else { return }
         
         let mutableString = richTextContext.attributedString.mutableCopy() as! NSMutableAttributedString
         
         guard mutableString.length > 0 else { return }
         
         // 전체 텍스트에 paragraph style 적용
         let paragraphStyle = NSMutableParagraphStyle()
         paragraphStyle.alignment = alignment
         
         let fullRange = NSRange(location: 0, length: mutableString.length)
         mutableString.addAttribute(.paragraphStyle, value: paragraphStyle, range: fullRange)
         
         richTextContext.setAttributedString(to: mutableString)
         currentTextAlignment = alignment
         
         DispatchQueue.main.async {
             self.saveCurrentEditingBlock()
             self.objectWillChange.send()
         }
     }
     
     // 현재 텍스트 정렬 상태 확인
     func getCurrentTextAlignment() -> NSTextAlignment {
         let attributedString = richTextContext.attributedString
         
         guard attributedString.length > 0 else { return .left }
         
         if let paragraphStyle = attributedString.attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSParagraphStyle {
             return paragraphStyle.alignment
         }
         
         return .left
     }
       

    
    // 현재 폰트명 가져오기
        func getCurrentFontName() -> String {
            let attributedString = richTextContext.attributedString
            
            guard attributedString.length > 0 else { return "NanumSquareNeoTTF-cBd" } // 기본값을 나눔스퀘어네오 볼드로
            
            // 선택된 범위가 있으면 해당 위치의 폰트를 확인
            let checkLocation: Int
            let selectedRange = richTextContext.selectedRange
            
            if selectedRange.location != NSNotFound && selectedRange.location < attributedString.length {
                checkLocation = selectedRange.location
            } else {
                checkLocation = 0
            }
            
            if let font = attributedString.attribute(.font, at: checkLocation, effectiveRange: nil) as? UIFont {
                return font.fontName
            }
            
            return "NanumSquareNeoTTF-cBd" // 기본값
        }
        
    // String 폰트명을 받는 기존 메서드 (호환성 유지)
    func setFontFamily(_ fontName: String) {
        guard editingTextBlock != nil else { return }
        
        let mutableString = richTextContext.attributedString.mutableCopy() as! NSMutableAttributedString
        guard mutableString.length > 0 else { return }
        
        let selectedRange = getSelectedRange(for: mutableString)
        
        // 실제 텍스트에서 현재 폰트 사이즈 가져오기
        var currentFontSize: CGFloat = 16.0 // 기본값
        if let existingFont = mutableString.attribute(.font, at: selectedRange.location, effectiveRange: nil) as? UIFont {
            currentFontSize = existingFont.pointSize
        }
        
        // 폰트명으로 폰트 생성
        if let newFont = UIFont(name: fontName, size: currentFontSize) {
            mutableString.addAttribute(.font, value: newFont, range: selectedRange)
            richTextContext.setAttributedString(to: mutableString)
            
            DispatchQueue.main.async {
                self.saveCurrentEditingBlock()
                self.objectWillChange.send()
            }
        }
    }

    // DivaryFontConvertible을 받는 새로운 메서드
    func setFontFamily(_ fontConvertible: DivaryFontConvertible) {
        guard editingTextBlock != nil else { return }
        
        let mutableString = richTextContext.attributedString.mutableCopy() as! NSMutableAttributedString
        guard mutableString.length > 0 else { return }
        
        let selectedRange = getSelectedRange(for: mutableString)
        
        // 실제 텍스트에서 현재 폰트 사이즈 가져오기
        var currentFontSize: CGFloat = 16.0 // 기본값
        if let existingFont = mutableString.attribute(.font, at: selectedRange.location, effectiveRange: nil) as? UIFont {
            currentFontSize = existingFont.pointSize
        }
        
        // DivaryFontConvertible을 사용해 폰트 생성
        let newFont = fontConvertible.font(size: currentFontSize)
        mutableString.addAttribute(.font, value: newFont, range: selectedRange)
        richTextContext.setAttributedString(to: mutableString)
        
        DispatchQueue.main.async {
            self.saveCurrentEditingBlock()
            self.objectWillChange.send()
        }
    }
        
        // 선택된 범위 또는 전체 범위 반환 (헬퍼 메서드)
    private func getSelectedRange(for mutableString: NSMutableAttributedString) -> NSRange {
        let range = richTextContext.selectedRange

        let isValidRange = range.location != NSNotFound &&
                           range.location >= 0 &&
                           range.location < mutableString.length &&
                           NSMaxRange(range) <= mutableString.length

        // 선택 범위가 유효하고 길이가 1 이상이면 그대로 사용
        if isValidRange && range.length > 0 {
            return range
        } else {
            // 그렇지 않으면 전체 텍스트 범위 반환
            return NSRange(location: 0, length: mutableString.length)
        }
    }

    
}
