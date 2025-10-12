//
//  EquipmentInputView.swift
//  Divary
//
//  Created by chohaeun on 7/18/25.
//

import SwiftUI

struct EquipmentInputView: View {
    
    //슈트 아이콘
    private func suitTypeImage(for suitType: String?) -> Image {
        guard let suitType = suitType else {
            return Image(systemName: "")
        }
        
        switch suitType {
        case "웻슈트 3mm": return Image("wet3")
        case "웻슈트 3mmB": return Image("wet3Blue")
        case "웻슈트 5mm": return Image("wet5")
        case "웻슈트 5mmB": return Image("wet5Blue")
        case "드라이 슈트": return Image("dry")
        case "드라이 슈트B": return Image("dryBlue")
        case "기타": return Image("exsuit")
        case "기타B": return Image("exsuitBlue")
        default: return Image("")
        }
    }
    
    //체감 무게 아이콘
    private func pweightImage(for pweight: String?) -> Image {
        guard let pweight = pweight else {
            return Image(systemName: "")
        }
        
        switch pweight {
        case "가벼움": return Image("light")
        case "가벼움B": return Image("lightBlue")
        case "보통": return Image("normal")
        case "보통B": return Image("normalBlue")
        case "무거움": return Image("heavy")
        case "무거움B": return Image("heavyBlue")
        default: return Image("")
        }
    }
    
    @Binding var equipment: DiveEquipment
    @State private var equipmentInput: String? = nil
    
    var body: some View {
        ZStack {
            VStack{
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        VStack(alignment: .leading, spacing: 10){
                            
                            //슈트 종류
                            Text("슈트 종류")
                                .font(Font.omyu.regular(size: 20))
                            
                            HStack{
                                IconSuitButton(
                                        options: SuitType.allDisplayNames,
                                        selected: equipment.suitType,
                                        imageProvider: suitTypeImage(for:),
                                        onSelect: { equipment.suitType = $0 },
                                        size: 30,
                                        isImage: true
                                    )
                            }
                        }
                        
                        //웨이트
                        NumberInputField(
                            title: "웨이트",
                            placeholder: "0",
                            unit: "kg",
                            value: $equipment.weight
                        )
                        
                        VStack(alignment: .leading, spacing: 10){
                            
                            //체감 무게
                            Text("체감 무게")
                                .font(Font.omyu.regular(size: 12))
                                .foregroundStyle(Color("grayscale_g500"))
                            
                            IconButton(
                                options: PerceivedWeightType.allDisplayNames,
                                selected: equipment.pweight,
                                imageProvider: pweightImage(for:),
                                onSelect: { equipment.pweight = $0 },
                                size: 30,
                                isImage: true
                            )
                        }
                        
                        //착용
                        TextInputField(
                            title: "착용",
                            placeholder: "내용을 입력하세요.",
                            unit: "",
                            value: $equipment.Equipment
                        )
                    }
                }
//                .padding(.horizontal, 11)
//                .padding(.vertical, 22)
//                .background(
//                    RoundedRectangle(cornerRadius: 10)
//                        .fill(Color(.white))
//                )
                .frame(maxWidth: .infinity, alignment: .center)
                //.padding(.horizontal)
            }
        }.onAppear {
            // 바인딩 강제 활성화 - 현재 값을 읽고 다시 설정
            let currentEquipment = equipment
            equipment = currentEquipment
        }
    }
}

#Preview {
    @Previewable @State var previewOverview = DiveEquipment(
       suitType: "웻슈트 3mm",
       Equipment:"",
       weight: nil
    )
    
    EquipmentInputView(equipment: $previewOverview)
}



struct IconSuitButton: View {
    let options: [String]
    let selected: String?
    let imageProvider: (String?) -> Image
    let onSelect: (String) -> Void
    let size: CGFloat
    var isImage: Bool = false
    // 화면 크기에 따른 버튼 크기 계산
    private var buttonSize: CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        
        if screenWidth >= 768 { // 아이패드
            return 190
        } else { // 아이폰
            return 80
        }
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 12) {
                ForEach(options, id: \.self) { option in
                    
                    Button(action: {
                        onSelect(option)
                    }) {
                        VStack(spacing: 4) {
                            
                            Spacer()
                            if isImage {
                                imageProvider(selected == option ? option + "B" : option)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: size, height: size)
                            } else {
                                imageProvider(option)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: size, height: size)
                            }
                            
                            Spacer()
                            
                            Text(option)
                                .font(Font.NanumSquareNeo.NanumSquareNeoRegular(size: 12))
                            
                            Spacer()
                        }
                        .padding(10)
                        .frame(width: buttonSize, height: buttonSize) // 디바이스별 고정 크기
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(
                                    selected == option ? Color.primary_sea_blue : Color.grayscale_g300
                                )
                        )
                        .foregroundStyle(selected == option ? Color.primary_sea_blue : Color.grayscale_g300)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 16)
        }
        .clipped()
    }
}
