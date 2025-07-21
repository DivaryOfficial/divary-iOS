//
//  EquipmentInputView.swift
//  Divary
//
//  Created by chohaeun on 7/18/25.
//

import SwiftUI

struct  EquipmentInputView: View {
    
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
        GeometryReader { geometry in
            ZStack {
                Color.gray.opacity(0.8)
                    .edgesIgnoringSafeArea(.all)
                
                VStack{
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            
                            VStack(alignment: .leading, spacing: 10){
                                
                                //슈트 종류
                                Text("슈트 종류")
                                    .font(Font.NanumSquareNeo.NanumSquareNeoBold(size: 14))
                                    
                                
                                HStack{
                                    
                                    IconButton(
                                    options: ["웻슈트 3mm", "웻슈트 5mm", "드라이 슈트", "기타"],
                                    selected: equipment.suitType,
                                    imageProvider: suitTypeImage(for:),
                                    onSelect: { equipment.suitType = $0 },
                                    size: 30, //폰트 12
                                    isImage: true
                                )
                            }
                            }
                            
                            //착용
                            ListInputField(
                                title: "착용",
                                placeholder: "ex) 후드, 장갑, 베스트 등",
                                list: $equipment.Equipment,
                                    value: $equipmentInput
                            )
                            
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
                                    options: ["가벼움", "보통", "무거움"],
                                    selected: equipment.pweight,
                                    imageProvider: pweightImage(for:),
                                    onSelect: { equipment.pweight = $0 },
                                    size: 30, //폰트 12
                                    isImage: true
                                )
                            }
                        }
                        
                    }
                    .padding(.horizontal, 11)
                    .padding(.vertical, 22)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.white))
                            .stroke(Color.grayscale_g300)
                    )
                    .frame(maxHeight: geometry.size.height * 0.67)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal)
                    
                }
            }
        }
    }
}



#Preview {
    
    @Previewable @State var previewOverview = DiveEquipment(
       suitType: "웻슈트 3mm",
       Equipment: [],
       weight: nil
    )
    
    EquipmentInputView(equipment: $previewOverview)
}

