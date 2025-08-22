//
//  OverViewInput.swift
//  Divary
//
//  Created by chohaeun on 7/18/25.
//

import SwiftUI

struct OverViewInputView: View {
    
    @Binding var overview: DiveOverview
    @FocusState private var focusedField: FocusedField?
    
    enum FocusedField {
        case title, point
    }
    
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
    
    var body: some View {
        ZStack {
            VStack{
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            
                            // 다이빙 지역
                            LocationTextInputField(
                                title: "다이빙 지역",
                                placeholder: "다이빙 지역을 입력해주세요 ex) 강원도 강릉",
                                unit: "돋보기",
                                value: Binding(
                                    get: { overview.title ?? "" },
                                    set: { newValue in
                                        overview.title = (newValue?.isEmpty == true) ? nil : newValue
                                    }
                                ),
                                focused: $focusedField,
                                focusValue: .title
                            )
                            .id("title")
                            
                            // 다이빙 포인트
                            TextInputField(
                                title: "다이빙 포인트",
                                placeholder: "ex) 문섬",
                                unit: "",
                                value: $overview.point,
                                focused: $focusedField,
                                focusValue: .point
                            )
                            .id("point")
                            
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
                        .padding(.horizontal, 20)
                        .padding(.vertical, 20)
                    }
                    .onChange(of: focusedField) { _, newValue in
                        guard let field = newValue else { return }
                        withAnimation(.easeInOut(duration: 0.3)) {
                            proxy.scrollTo(field.scrollId, anchor: .center)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
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
        .buttonStyle(PlainButtonStyle())
    }
}

extension OverViewInputView.FocusedField {
    var scrollId: String {
        switch self {
        case .title: return "title"
        case .point: return "point"
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
