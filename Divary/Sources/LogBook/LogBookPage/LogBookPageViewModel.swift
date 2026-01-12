//
//  LogBookPageViewModel.swift
//  Divary
//
//  Created by chohaeun on 8/6/25.
//

import SwiftUI

@Observable
class LogBookPageViewModel {
    var mainViewModel: LogBookMainViewModel
    var isSaved: Bool = false
    var activeInputSection: InputSectionType? = nil
    
    // 임시저장 관련 상태
    var showUnsavedAlert = false
    var showTempSavedMessage = false
    
    init(mainViewModel: LogBookMainViewModel) {
        self.mainViewModel = mainViewModel
    }
    
    // ✅ X 버튼 클릭 처리 (인덱스 제거)
    func handleCloseButtonTap() {
        // 1. 변경사항이 없으면 그냥 닫기
        if !mainViewModel.hasChangesFromLastSave() {
            withAnimation {
                activeInputSection = nil
            }
            return
        }
        
        // 2. 변경사항이 있으면 알림 표시
        showUnsavedAlert = true
    }
    
    // ✅ 프론트엔드 임시저장하고 나가기 (인덱스 제거)
    func handleTempSave() {
        // 프론트엔드에만 임시저장 (API 호출 X)
        mainViewModel.saveFrontendTemp()
        
        // 임시저장 완료 메시지 표시
        withAnimation {
            showTempSavedMessage = true
            activeInputSection = nil
        }
        
        // 2초 후 메시지 숨기기
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                self.showTempSavedMessage = false
            }
        }
        
        DebugLogger.success("프론트엔드 임시저장 완료")
    }
    
    // ✅ 그냥 나가기 (입력 취소 - 인덱스 제거)
    func handleDiscardChanges() {
        // 현재 입력을 취소하고 이전 상태로 복원
        mainViewModel.discardCurrentInput()
        
        withAnimation {
            activeInputSection = nil
        }
        
        DebugLogger.success("입력 취소 완료")
    }
}
