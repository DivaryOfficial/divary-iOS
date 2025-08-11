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
    var selectedPage: Int = 0
    var isSaved: Bool = false
    var activeInputSection: InputSectionType? = nil
    
    // 임시저장 관련 상태
    var showUnsavedAlert = false
    var showTempSavedMessage = false
    
    init(mainViewModel: LogBookMainViewModel) {
        self.mainViewModel = mainViewModel
    }
    
    // X 버튼 클릭 처리
    func handleCloseButtonTap() {
        // 1. 임시저장 상태이고 변경사항이 없으면 그냥 닫기
        if mainViewModel.isTempSaved && !mainViewModel.hasChangesFromTempSave(for: selectedPage) {
            withAnimation {
                activeInputSection = nil
            }
            return
        }
        
        // 2. 모든 섹션이 완성되었으면 그냥 닫기
        if mainViewModel.areAllSectionsComplete(for: selectedPage) {
            withAnimation {
                activeInputSection = nil
            }
        } else {
            // 3. 미완성이고 변경사항이 있으면 알림 표시
            showUnsavedAlert = true
        }
    }
    
    // 임시저장하고 나가기
    func handleTempSave() {
        // API 기반 임시저장
        mainViewModel.saveLogBook(at: selectedPage, saveStatus: .temp) { [weak self] success in
            DispatchQueue.main.async {
                if success {
                    // 임시저장 완료 메시지 표시
                    withAnimation {
                        self?.showTempSavedMessage = true
                        self?.activeInputSection = nil
                    }
                    
                    // 2초 후 메시지 숨기기
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            self?.showTempSavedMessage = false
                        }
                    }
                } else {
                    // 에러는 mainViewModel에서 처리됨
                    self?.activeInputSection = nil
                }
            }
        }
    }
    
    // 그냥 나가기 (변경사항 버리기)
    func handleDiscardChanges() {
        // 임시저장된 상태가 있으면 임시저장된 데이터로 되돌리기
        if mainViewModel.isTempSaved {
            mainViewModel.restoreFromTempSave(for: selectedPage)
        } else {
            // 임시저장이 없으면 모든 필드 초기화
            mainViewModel.clearAllFields(for: selectedPage)
        }
        
        withAnimation {
            activeInputSection = nil
        }
    }
}
