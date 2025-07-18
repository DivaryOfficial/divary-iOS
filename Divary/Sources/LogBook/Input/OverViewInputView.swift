//
//  OverViewInput.swift
//  Divary
//
//  Created by chohaeun on 7/18/25.
//

import SwiftUI

struct OverViewInputView: View {
    
    //방법 아이콘
    private func methodImage(for method: String?) -> Image {
        guard let method = method else {
            return Image(systemName: "")
        }
        
        switch method {
        case "비치": return Image("parasolGray")
        case "비치B": return Image("parasolBlue")
        case "보트": return Image("boat")
        case "보트B": return Image("BoatBlue")
        case "기타": return Image("anchor")
        case "기타B": return Image("anchorBlue")
        default: return Image("")
        }
    }
    
    
    @Binding var overview: DiveOverview
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.gray.opacity(0.8)
                    .edgesIgnoringSafeArea(.all)
                
                VStack{
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            
                            // 다이빙 지역
                            TextInputField(
                                title: "다이빙 지역",
                                placeholder: "다이빙 지역을 입력해주세요 ex) 강원도 강릉",
                                unit: "돋보기",
                                value: $overview.title
                            )
                            
                            // 다이빙 포인트
                            TextInputField(
                                title: "다이빙 포인트",
                                placeholder: "ex) 문섬",
                                unit: "",
                                value: $overview.point
                            )
                            
                            //다이빙 방법
                            Text("다이빙 방법")
                                .font(Font.omyu.regular(size: 20))
                            
                            IconButtonRow(
                                options: ["비치", "보트", "기타"],
                                selected: overview.method,
                                imageProvider: methodImage(for:),
                                onSelect: { overview.method = $0 },
                                size: 53
                            )
                            
                            //다이빙 목적
                            Text("다이빙 목적")
                                .font(Font.omyu.regular(size: 20))
                            
                            HStack(spacing: 16) {
                                Spacer()
                                
                                ForEach(["펀 다이빙", "교육 다이빙"], id: \.self) { option in
                                    purposeButton(option: option)
                                }
                                Spacer()
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
                    .frame(maxHeight: geometry.size.height * 0.64)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal)
                    
                }
            }
        }
    }
    
    private func purposeButton(option: String) -> some View {
        let isSelected = overview.purpose == option
        return Button(action: {
            overview.purpose = option
        }) {
            Text(option)
                .font(.system(size: 16))
                .foregroundColor(isSelected ? Color("primary_sea_blue") : Color("grayscale_g400"))
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color("primary_sea_blue").opacity(0.1) : Color("grayscale_g100"))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color("primary_sea_blue") : Color.clear, lineWidth: 1)
                )
        }
    }
}



#Preview {
    
    @Previewable @State var previewOverview = DiveOverview(
        title: "제주 서귀포",
        point: "apfhd",
        purpose: "펀", method: "보트"
    )
    
    OverViewInputView(overview: $previewOverview)
}

