//
//  StoreMainView.swift
//  Divary
//
//  Created by 바견규 on 7/26/25.
//

import SwiftUI

//상단 탭 enum
enum StoreTab: String, CaseIterable {
    case myOcean = "나의 바다"
    case wardrobe = "옷장"
}

// 나의 바다 모달 탭
enum MyOceanTabType: String, CaseIterable {
    case oceanThema = "바다 테마"
    case buddyPet = "버디 펫"
}

// 옷장 모달 탭
enum wardrobeTabType: String, CaseIterable {
    case skin = "스킨"
    case diverItem = "다이버 아이템"
}


struct StoreMainView: View {
    // 모달 시트
    @State private var showSheet = true
    // 탭 바
    @State var selectedTab: StoreTab = .myOcean
    // 나의 바다 모달 탭
    @State private var MyOceanTab: MyOceanTabType = .oceanThema
    // 옷장 모달 탭
    @State private var wardrobeTab: wardrobeTabType = .skin
    
    // 펫 편집 모드 상태
    @State private var isPetEditingMode = false
    
    // 토스트 메시지 상태
    @State private var showToast = false
    
    @Bindable var viewModel:CharacterViewModel
    
    
    var body: some View {
        ZStack{
            Color.white
            CharacterView(
                viewModel: viewModel,
                isStoreView: !isPetEditingMode,  // 편집 모드일 때는 스토어 뷰가 아닌 상태로
                isPetEditingMode: $isPetEditingMode
            )
            
            VStack{
                VStack(spacing: 0) {
                    if showSheet && !isPetEditingMode {  // 편집 모드가 아닐 때만 시트 표시
                        StoreNavBar(showSheet: $showSheet)
                        TabSelector(selectedTab: $selectedTab)
                            .padding(.horizontal)
                    }
                }
                .background(Color.white)
                
                
                
                
                if showSheet && !isPetEditingMode {  // 편집 모드가 아닐 때만 시트 표시
                    Group {
                        switch selectedTab {
                        case .myOcean:
                            BottomSheetView(
                                minHeight: UIScreen.main.bounds.height * 0.05,
                                medianHeight: UIScreen.main.bounds.height * 0.5,
                                maxHeight: UIScreen.main.bounds.height * 0.8
                            ) {
                                MyOceanStore()
                            }
                        case .wardrobe:
                            BottomSheetView(
                                minHeight: UIScreen.main.bounds.height * 0.05,
                                medianHeight: UIScreen.main.bounds.height * 0.5,
                                maxHeight: UIScreen.main.bounds.height * 0.8
                            ) {
                                MyWardrobeStore()
                            }
                        }
                    }
                }
                
                
            }
            
            // 토스트 메시지
            if showToast {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text("상점에서는 캐릭터와 펫이 실제 위치보다 아래에 표시됩니다.")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.black.opacity(0.8))
                            )
                            .transition(.asymmetric(
                                insertion: .move(edge: .bottom).combined(with: .opacity),
                                removal: .opacity
                            ))
                        Spacer()
                    }
                    .padding(.bottom, 40) // 하단 시트 위에 표시
                }
            }
            
        }
        .onChange(of: isPetEditingMode) { oldValue, newValue in
            // 펫 편집 모드에서 나올 때 (true -> false)
            if oldValue == true && newValue == false {
                showToastMessage()
            }
        }
        
        
    }
    
    // 토스트 메시지 표시 함수
    private func showToastMessage() {
        withAnimation(.easeInOut(duration: 0.3)) {
            showToast = true
        }
        
        // 2초 후 자동으로 사라지게
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeInOut(duration: 0.3)) {
                showToast = false
            }
        }
    }
    
    // MARK: - MyOceanStore
    @ViewBuilder
    private func MyOceanStore() -> some View {
        TopTabView(selectedTab: $MyOceanTab)
        switch MyOceanTab {
        case .oceanThema:
            oceanThema()
        case .buddyPet:
            buddyPet()
        }
    }
    
    //Mark: - 모달뷰 바다 테마 파트
    struct StoreItem: Identifiable {
        let id = UUID()
        let image: String
        let text: String
        let type: BackgroundType
    }
    
    
    
    // MARK: - oceanThema
    @ViewBuilder
    private func oceanThema() -> some View {
        let items: [StoreItem] = [
            StoreItem(image: "CoralForestStore", text: "산호숲", type: .coralForest),
            StoreItem(image: "EmeraldStore", text: "에메랄드", type: .emerald),
            StoreItem(image: "PinkLakeStore", text: "핑크호수", type: .pinkLake),
            StoreItem(image: "ShipWreckStore", text: "난파선", type: .shipWreck)
        ]

        let columns = [
            GridItem(.flexible()),
            GridItem(.flexible())
        ]

        ScrollView {
            Spacer().frame(height: 20)
            LazyVGrid(columns: columns, spacing: 30) {
                ForEach(items) { item in
                    OceanThemaStoreComponent(
                        imgText: item.image,
                        componentText: item.text,
                        isSelected: viewModel.customization?.background == item.type,
                        onSelected: {
                            viewModel.customization = viewModel.customization?.copy(background: item.type)
                        }
                    )
                }
            }
            .padding(.bottom)
            .padding(.horizontal, 12)
        }
    }

    // MARK: - buddyPet
    @ViewBuilder
    private func buddyPet() -> some View {
        BuddyPetView(
            viewModel: viewModel,
            isPetEditingMode: $isPetEditingMode
        )
    }
    
    struct BuddyPetView: View {
        @Bindable var viewModel: CharacterViewModel
        @Binding var isPetEditingMode: Bool
        // 물고기 선택 상태 관리
        @State var isFishSelected = false
        
        var body: some View {
            VStack(spacing: 22) {
                // 펫 그리드
                ScrollView {
                    let columns = [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ]
                    
                    // 물고기를 제외한 펫들
                    let nonFishPets = PetType.allCases.filter { $0 != .expectedGray && $0 != .expectedBlue }
                    
                    LazyVGrid(columns: columns, spacing: 16) {
                        
                        // 나머지 펫들
                        ForEach(nonFishPets, id: \.self) { petType in
                            PetSelectionCard(
                                petType: petType,
                                viewModel: viewModel,
                                isFishSelected: $isFishSelected,
                                isPetEditingMode: $isPetEditingMode
                            )
                        }
                        
                        // 출시 예정
                        FishPetCard(
                            viewModel: viewModel,
                            isFishSelected: $isFishSelected
                        )
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
    }


    
    // MARK: - MyWardrobeStore
    @ViewBuilder
    private func MyWardrobeStore() -> some View {
        TopTabView(selectedTab: $wardrobeTab)
        switch wardrobeTab {
        case .skin:
            skin()
        case .diverItem:
            diverItem()
        }
    }
    

    // MARK: - skin
    @State private var selectedBodyColor: Int? = 1
    @State private var selectedCheekColor: Int? = 0
    @State private var selectedSpeechBubble: Int? = 1

    private func colorForBody(_ type: CharacterBodyType) -> Color {
        switch type {
        case .ivory: return Color(hex: "#FFFDF6")
        case .yellow: return Color(hex: "#FFF6D2")
        case .pink: return Color(hex: "#FFE929")
        case .brown: return Color(hex: "#AF9685")
        case .gray: return Color(hex: "#7B8184")
        default: return .clear
        }
    }

    private func colorForCheek(_ type: CheekType) -> Color {
        switch type {
        case .pastelPink: return Color(hex: "#FFD4D4")
        case .salmon: return Color(hex: "#FFD4C7")
        case .orange: return Color(hex: "#FFAD94")
        case .coral: return Color(hex: "#FFA6A6")
        case .pink: return Color(hex: "#FFC2FF")
        default: return .clear
        }
    }
    
    @ViewBuilder
    private func speechBubbleItemView(for type: SpeechBubbleType, isSelected: Bool) -> some View {
        let imageName = isSelected ? type.clickedImageName : type.defaultImageName
        
        Image(imageName)
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
    
    @ViewBuilder
    private func skin() -> some View {
        ScrollView{
            LazyVStack(alignment: .leading, spacing: 24) {
                // 바디 색상
                Text("바디 색상")
                    .font(Font.omyu.regular(size: 20))
                    .foregroundStyle(Color.bw_black)
                
                HStack(spacing: 16) {
                    ForEach(CharacterBodyType.allCases.filter { $0 != .none }, id: \.self) { type in
                        let isSelected = viewModel.customization?.body == type
                        Circle()
                            .fill(colorForBody(type))
                            .overlay(
                                ZStack {
                                    Circle()
                                        .stroke(isSelected ? Color.primary_sea_blue : Color.grayscale_g300, lineWidth: 1)
                                    
                                    if isSelected {
                                        Image("humbleicons_check")
                                            .resizable()
                                            .scaledToFit()
                                            .scaleEffect(0.4)
                                            .foregroundStyle(Color.primary_sea_blue) // 선택 시 체크 아이콘 색상
                                        
                                    }
                                }
                            )
                            .onTapGesture {
                                viewModel.customization = viewModel.customization?.copy(body: type)
                            }
                    }
                }
                
                // 볼터치 색상
                Text("볼터치 색상")
                    .font(Font.omyu.regular(size: 20))
                    .foregroundStyle(Color.bw_black)
                
                HStack(spacing: 16) {
                    ForEach(CheekType.allCases.filter { $0 != .none }, id: \.self) { type in
                        let isSelected = viewModel.customization?.cheek == type
                        Circle()
                            .fill(colorForCheek(type))
                            .overlay(
                                ZStack {
                                    Circle()
                                        .stroke(isSelected ? Color.primary_sea_blue : Color.grayscale_g300, lineWidth: 1)
                                    
                                    if isSelected {
                                        Image("humbleicons_check")
                                            .resizable()
                                            .scaledToFit()
                                            .scaleEffect(0.4)
                                            .foregroundStyle(Color.primary_sea_blue) // 선택 시 체크 아이콘 색상
                                        
                                    }
                                }
                            )
                            .onTapGesture {
                                viewModel.customization = viewModel.customization?.copy(cheek: type)
                            }
                    }
                }
                
                // 말풍선
                Text("말풍선")
                    .font(Font.omyu.regular(size: 20))
                    .foregroundStyle(Color.bw_black)
                
                HStack(spacing: 16) {
                    ForEach(SpeechBubbleType.allCases, id: \.self) { type in
                        let isSelected = viewModel.customization?.speechBubble == type
                        speechBubbleItemView(for: type, isSelected: isSelected)
                            .onTapGesture {
                                viewModel.customization = viewModel.customization?.copy(speechBubble: type)
                                viewModel.speechTextBinding.wrappedValue = ""
                            }
                    }
                }
            }
            .padding(.vertical)
            .padding(.horizontal, 12)
        }
    }



    // MARK: - diverItem
    @ViewBuilder
    private func diverItem() -> some View {
        
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 16) {
                ItemSelectionSection(
                    title: "마스크",
                    items: MaskType.allCases,
                    selectedItem: viewModel.customization?.mask,
                    imageWidth: 67,
                    noneSize:40,
                    noneHorizontalPadding:24,
                    noneVerticalPadding:11
                ) { selected in
                    viewModel.customization = viewModel.customization?.copy(mask: selected)
                }
                
                ItemSelectionSection(
                    title: "레귤레이터",
                    items: RegulatorType.allCases,
                    selectedItem: viewModel.customization?.regulator,
                    imageWidth: 67,
                    noneSize:40,
                    noneHorizontalPadding:26,
                    noneVerticalPadding:12
                ) { selected in
                    viewModel.customization = viewModel.customization?.copy(regulator: selected)
                }
                
                ItemSelectionSection(
                    title: "핀",
                    items: PinType.allCases,
                    selectedItem: viewModel.customization?.pin,
                    imageWidth: 67,
                    noneSize:60,
                    noneHorizontalPadding:12,
                    noneVerticalPadding:12
                ) { selected in
                    viewModel.customization = viewModel.customization?.copy(pin: selected)
                }
                
                ItemSelectionSection(
                    title: "탱크",
                    items: TankType.allCases,
                    selectedItem: viewModel.customization?.tank,
                    imageWidth: 67,
                    noneSize:70,
                    noneHorizontalPadding:9,
                    noneVerticalPadding:15
                ) { selected in
                    viewModel.customization = viewModel.customization?.copy(tank: selected)
                }
            }
            .padding(.vertical)
            .padding(.horizontal, 12)
        }
    }


    
}





#Preview {
    @Previewable var viewModel = CharacterViewModel()
    StoreMainView(viewModel: viewModel)
}
