//
//  MyProfileViewModel.swift
//  Divary
//
//  Created by 김나영 on 11/13/25.
//

import Foundation
import Combine

final class MyProfileViewModel: ObservableObject {
    
    // MARK: - Published Properties (View Binds To)
    
    /// (읽기 전용)
    @Published var userId: String = "로딩 중..."
    
    /// (편집 가능)
    @Published var organization: String = ""
    
    /// (편집 가능)
    @Published var selectedLevel: DiveLevel = .openWater
    
    // MARK: - Private Properties
    
    private let memberService: MemberService
    private var cancellables = Set<AnyCancellable>()
    
    /// API로 최초에 로드한 값.
    /// 이 값과 비교하여 변경되었을 때만 '저장' API를 호출합니다.
    private var initialOrganization: String = ""
    private var initialLevel: DiveLevel = .openWater
    
    // MARK: - Init
    
    init(memberService: MemberService) {
        self.memberService = memberService
    }
    
    // MARK: - Public Methods (Called by View)
    
    /// 뷰가 나타날 때 프로필 정보를 불러옵니다.
    func fetchProfile() {
        memberService.getProfile()
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("⛔️ getProfile 에러: \(error.localizedDescription)")
                    self.userId = "에러 발생"
                }
            }, receiveValue: { [weak self] profile in
                guard let self = self else { return }
                
                // 1. API 응답(String)을 뷰에서 쓰는 DiveLevel(Enum)으로 변환
                //    (DiveLevel(apiValue:)는 View 파일에서 정의)
                let level = DiveLevel(apiValue: profile.level) ?? .openWater
                
                // 2. @Published 프로퍼티 업데이트 (View가 갱신됨)
                self.userId = profile.id
                self.organization = profile.memberGroup
                self.selectedLevel = level
                
                // 3. "최초 값" 저장 (나중에 비교용)
                self.initialOrganization = profile.memberGroup
                self.initialLevel = level
                
                print("✅ 프로필 로드 성공: \(profile.id)")
            })
            .store(in: &cancellables)
    }
    
    /// 뷰가 사라질 때 변경된 사항을 저장합니다.
    func saveChangesOnDisappear() {
        // 1. 단체가 변경되었는지 확인
        if organization != initialOrganization {
            saveGroup(group: organization)
        }
        
        // 2. 레벨이 변경되었는지 확인
        // (selectedLevel.apiValue는 View 파일에서 정의)
        if selectedLevel != initialLevel {
            saveLevel(level: selectedLevel.apiValue)
        }
    }
    
    // MARK: - Private API Callers
    
    private func saveGroup(group: String) {
        print("🆙 단체 정보 업데이트 시도: \(group)")
        memberService.updateGroup(group: group)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("⛔️ updateGroup 에러: \(error.localizedDescription)")
                }
            }, receiveValue: { _ in
                print("✅ 단체 정보 업데이트 성공")
                // 저장 성공 시, "최초 값"도 갱신
                self.initialOrganization = group
            })
            .store(in: &cancellables)
    }
    
    private func saveLevel(level: String) {
        print("🆙 레벨 정보 업데이트 시도: \(level)")
        memberService.updateLevel(level: level)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("⛔️ updateLevel 에러: \(error.localizedDescription)")
                }
            }, receiveValue: { _ in
                print("✅ 레벨 정보 업데이트 성공")
                // 저장 성공 시, "최초 값"도 갱신
                self.initialLevel = self.selectedLevel
            })
            .store(in: &cancellables)
    }
}
