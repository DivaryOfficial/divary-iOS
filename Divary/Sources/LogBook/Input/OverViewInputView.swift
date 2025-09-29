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
        case "비치": return Image("parasol")
        case "비치B": return Image("parasolBlue")
        case "보트": return Image("boat")
        case "보트B": return Image("boatBlue")
        case "기타": return Image("anchor")
        case "기타B": return Image("anchorBlue")
        default: return Image("")
        }
    }
    
    @Binding var overview: DiveOverview
    
    var body: some View {
        ZStack {
            VStack{
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // 다이빙 지역
                        LocationTextInputField(
                            title: "다이빙 지역",
                            placeholder: "내용을 입력하세요.",
                            unit: "돋보기",
                            value: Binding(
                                get: { overview.title ?? "" },
                                set: { newValue in
                                    overview.title = (newValue?.isEmpty == true) ? nil : newValue
                                }
                            )
                        )
                        
                        // 다이빙 포인트
                        TextInputField(
                            title: "내용을 입력하세요.",
                            placeholder: "ex) 문섬",
                            unit: "",
                            value: $overview.point
                        )
                        
                        //다이빙 방법
                        Text("다이빙 방법")
                            .font(Font.omyu.regular(size: 20))
                        
                        IconButton(
                            options: DivingMethodType.allDisplayNames,
                            selected: overview.method,
                            imageProvider: methodImage(for:),
                            onSelect: { overview.method = $0 },
                            size: 45,
                            isImage: true
                        )
                        
                        //다이빙 목적
                        Text("다이빙 목적")
                            .font(Font.omyu.regular(size: 20))
                        
                        HStack(spacing: 5) {
                            ForEach(DivingPurposeType.allDisplayNames, id: \.self) { option in
                                purposeButton(option: option)
                            }
                        }
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
            let currentOverView = overview
            overview = currentOverView
        }
    }
    
    private func purposeButton(option: String) -> some View {
        let isSelected = overview.purpose == option
        
        return Button(action: {
            overview.purpose = option
        }) {
            Text(option)
                .font(.system(size: 12))
                .foregroundStyle(isSelected ? Color(.white) : Color("grayscale_g400"))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, 14)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? Color("primary_sea_blue") : Color("grayscale_g100"))
                )
        }
    }
}

#Preview {
    @Previewable @State var previewOverview = DiveOverview(
        title: "제주 서귀포",
        point: "apfhd",
        purpose: "펀",
        method: "보트"
    )
    
    OverViewInputView(overview: $previewOverview)
}
