//
//  CharacterViewModel.swift
//  Divary
//
//  Created by 바견규 on 7/25/25.
//

import SwiftUI

@Observable
class CharacterViewModel: Equatable, Hashable {
    var customization: CharacterCustomization?
    private let avatarService: AvatarService
    var isLoading = false
    var errorMessage: String?
    
    // Equatable을 위한 고유 ID
        let id = UUID()
    
    // 말풍선 입력을 위한 Binding 생성자
    var speechTextBinding: Binding<String> {
        Binding(
            get: { self.customization?.speechText ?? "" },
            set: { newText in
                if let current = self.customization {
                    self.customization = current.copy(speechText: newText)
                }
            }
        )
    }
    
    // MARK: - Equatable & Hashable 구현
    static func == (lhs: CharacterViewModel, rhs: CharacterViewModel) -> Bool {
            return lhs.id == rhs.id
        }
    
    func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    
    init(avatarService: AvatarService, isMockData: Bool) {
        self.avatarService = avatarService
        if isMockData {
            customization = CharacterCustomization(
                CharacterName: "하루",
                background: .coralForest,
                tank: .white,
                pin: .pink,
                regulator: .blue,
                cheek: .none,
                mask: .yellow,
                body: .gray,
                pet: PetCustomization(
                    type: .axolotl,
                    offset: CGSize(width: -100, height: 250),
                    rotation: .degrees(40)
                ),
                speechBubble: .rectangleTail,
                speechText: "다이빙하러 갈 사람"
            )
        }
    }

    // MARK: - API Methods
    /// 서버에서 아바타 정보 불러오기
    func loadAvatarFromServer() {
        isLoading = true
        errorMessage = nil
        
        avatarService.getAvatar { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let avatarResponse):
                    self?.convertResponseToCustomization(avatarResponse)
                    print(avatarResponse)
                    print("아바타 불러오기 성공")
                    
                case .failure(let error):
                    self?.errorMessage = "아바타를 불러오는데 실패했습니다: \(error.localizedDescription)"
                    print("아바타 불러오기 실패: \(error)")
                    // 실패 시 기본 아바타 설정
                    self?.setDefaultAvatar()
                }
            }
        }
    }
    
    /// 현재 아바타 정보를 서버에 저장
    func saveAvatarToServer() {
        guard let customization = self.customization else {
            errorMessage = "저장할 아바타 정보가 없습니다."
            return
        }
        
        let avatarRequest = convertCustomizationToRequest(customization)
        isLoading = true
        errorMessage = nil
        
        avatarService.saveAvatar(avatar: avatarRequest) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(_):
                    // 저장 성공 시, 서버 응답으로 완전히 덮어쓰지 않고 현재 상태 유지
                    print("아바타 저장 성공")
                    print(avatarRequest)
                case .failure(let error):
                    self?.errorMessage = "아바타 저장에 실패했습니다: \(error.localizedDescription)"
                    print("전송한 데이터:")
                    self?.printRequestData(avatarRequest)
                    print("아바타 저장 실패: \(error)")
                }
            }
        }
    }
    
    // MARK: - Data Conversion Methods
    
    /// AvatarResponseDTO를 CharacterCustomization으로 변환
    private func convertResponseToCustomization(_ response: AvatarResponseDTO) {
        // 서버 응답을 클라이언트 enum으로 변환
        let background = BackgroundType.fromServerValue(response.theme)
        let tank = TankType.fromServerValue(response.tank)
        let pin = PinType.fromServerValue(response.pin)
        let regulator = RegulatorType.fromServerValue(response.regulator)
        let cheek = CheekType.fromServerValue(response.cheekColor)
        let mask = MaskType.fromServerValue(response.mask)
        let body = CharacterBodyType.fromServerValue(response.bodyColor)
        let speechBubble = SpeechBubbleType.fromServerValue(response.speechBubble)
        
        // 펫 정보 변환
        var pet = PetCustomization(type: .none)
           if let buddyPetInfo = response.buddyPetInfo,
              let petTypeString = buddyPetInfo.budyPet,
              !petTypeString.isEmpty,
              let offset = buddyPetInfo.offset {
               
               let petType = PetType.fromServerValue(petTypeString)
               let rotationValue = buddyPetInfo.rotation ?? 0.0
               
               pet = PetCustomization(
                   type: petType,
                   offset: CGSize(
                       width: offset.width,
                       height: offset.height
                   ),
                   rotation: .degrees(rotationValue)
               )
           }
        
        // CharacterCustomization 생성
        self.customization = CharacterCustomization(
            CharacterName: response.name,
            background: background,
            tank: tank,
            pin: pin,
            regulator: regulator,
            cheek: cheek,
            mask: mask,
            body: body,
            pet: pet,
            speechBubble: speechBubble,
            speechText: response.bubbleText
        )
        
        print("서버 응답 변환 완료:")
        print("  - 이름: \(response.name ?? "없음")")
        print("  - 배경: \(response.theme ?? "없음") -> \(background.rawValue)")
        print("  - 몸통: \(response.bodyColor ?? "없음") -> \(body.rawValue)")
        print("  - 펫: \(response.buddyPetInfo?.budyPet ?? "없음") -> \(pet.type.rawValue)")
    }
    
    /// CharacterCustomization을 AvatarRequestDTO로 변환
    private func convertCustomizationToRequest(_ customization: CharacterCustomization) -> AvatarRequestDTO {
        var buddyPetInfo: BuddyPetInfoDTO? = nil
        
        // 펫이 none이 아닌 경우에만 buddyPetInfo 생성
        if customization.pet.type != .none,
           let serverPetValue = customization.pet.type.serverValue {
            buddyPetInfo = BuddyPetInfoDTO(
                budyPet: serverPetValue,
                rotation: customization.pet.rotation.degrees,
                offset: Offset(
                    width: customization.pet.offset.width,
                    height: customization.pet.offset.height
                )
            )
        }
        
        let request = AvatarRequestDTO(
            name: customization.CharacterName?.isEmpty == false ? customization.CharacterName : nil,
            tank: customization.tank.serverValue,
            bodyColor: customization.body.serverValue,
            buddyPetInfo: buddyPetInfo,
            bubbleText: customization.speechText?.isEmpty == false ? customization.speechText : nil,
            cheekColor: customization.cheek.serverValue,
            speechBubble: customization.speechBubble.serverValue,
            mask: customization.mask.serverValue,
            pin: customization.pin.serverValue,
            regulator: customization.regulator.serverValue,
            theme: customization.background.serverValue
        )
        
        print("클라이언트 데이터 변환 완료:")
        print("  - 배경: \(customization.background.rawValue) -> \(request.theme)")
        print("  - 몸통: \(customization.body.rawValue) -> \(request.bodyColor)")
        print("  - 펫: \(customization.pet.type.rawValue) -> \(buddyPetInfo?.budyPet ?? "nil")")
        
        return request
    }
    
    /// 기본 아바타 설정
    private func setDefaultAvatar() {
        self.customization = CharacterCustomization(
            CharacterName: nil,
            background: .coralForest,
            tank: .none,
            pin: .none,
            regulator: .none,
            cheek: .none,
            mask: .none,
            body: .ivory,
            pet: PetCustomization(type: .none),
            speechBubble: .none,
            speechText: nil
        )
        print("기본 아바타로 설정됨")
    }
    
    /// 요청 데이터 디버그 출력
    private func printRequestData(_ request: AvatarRequestDTO) {
        if let jsonData = try? JSONEncoder().encode(request),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            print("아바타 저장 요청 데이터: \(jsonString)")
        }
    }

    // MARK: - Helper Methods
    
    func imageName(for part: String) -> String {
        guard let c = customization else { return "" }

        switch part {
        case "background":
            return c.background.rawValue
        case "tank":
            return c.tank == .none ? "" : c.tank.rawValue
        case "pin":
            return c.pin == .none ? "" : c.pin.rawValue
        case "regulator":
            return c.regulator == .none ? "" : c.regulator.rawValue
        case "cheek":
            return c.cheek == .none ? "" : c.cheek.rawValue
        case "mask":
            return c.mask == .none ? "" : c.mask.rawValue
        case "body":
            return c.body.rawValue
        case "pet":
            return c.pet.type == .none ? "" : c.pet.type.rawValue
        default:
            return ""
        }
    }
    
    func updateCharacterName(_ name: String) {
        if let current = customization {
            customization = current.copy(CharacterName: name)
        }
    }
    
    func updateBackground(_ background: BackgroundType) {
        if let current = customization {
            customization = current.copy(background: background)
        }
    }
    
    func updateBodyColor(_ body: CharacterBodyType) {
        if let current = customization {
            customization = current.copy(body: body)
        }
    }
    
    func updatePet(_ pet: PetCustomization) {
        if let current = customization {
            customization = current.copy(pet: pet)
        }
    }
    
    func updateTank(_ tank: TankType) {
        if let current = customization {
            customization = current.copy(tank: tank)
        }
    }
    
    func updatePin(_ pin: PinType) {
        if let current = customization {
            customization = current.copy(pin: pin)
        }
    }
    
    func updateRegulator(_ regulator: RegulatorType) {
        if let current = customization {
            customization = current.copy(regulator: regulator)
        }
    }
    
    func updateCheek(_ cheek: CheekType) {
        if let current = customization {
            customization = current.copy(cheek: cheek)
        }
    }
    
    func updateMask(_ mask: MaskType) {
        if let current = customization {
            customization = current.copy(mask: mask)
        }
    }
    
    func updateSpeechBubble(_ speechBubble: SpeechBubbleType) {
        if let current = customization {
            customization = current.copy(speechBubble: speechBubble)
        }
    }
    
    func updateSpeechText(_ text: String) {
        if let current = customization {
            customization = current.copy(speechText: text)
        }
    }
}
