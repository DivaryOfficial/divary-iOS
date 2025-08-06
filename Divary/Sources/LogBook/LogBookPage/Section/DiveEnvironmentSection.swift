//
//  SwiftUIView.swift
//  Divary
//
//  Created by 바견규 on 7/9/25.
//

import SwiftUI

struct DiveEnvironmentSection: View {
    @Binding var environment: DiveEnvironment?
    @Binding var isSaved: Bool
    
    // 기입 상태
    var status: SectionStatus {
        Self.getStatus(environment: environment, isSaved: isSaved)
    }
    
    // Static 메서드로 분리
    static func getStatus(environment: DiveEnvironment?, isSaved: Bool) -> SectionStatus {
        if isSaved { // 사용자가 저장했으면 무조건 .complete
            return .complete
        }
        
        let values: [Any?] = [
            environment?.weather,
            environment?.wind,
            environment?.current,
            environment?.wave,
            environment?.airTemp,
            environment?.waterTemp,
            environment?.visibility
        ]
        if values.allSatisfy({ ($0 as? String)?.isEmpty ?? $0 == nil }) {
            return .empty
        } else if values.allSatisfy({ ($0 as? String)?.isEmpty == false || $0 != nil }) {
            return .complete
        } else {
            return .partial
        }
    }
    
    // 시야 아이콘
    private func visibilityImage(for visibility: String?) -> Image {
        guard let visibility = visibility else {
            return Image(systemName: "")
        }
        
        switch visibility {
        case "좋음": return Image("mynaui_baby")   // 좋은 시야
        case "보통": return Image("mynaui_annoyed-circle")  // 보통 시야
        case "나쁨": return Image("mynaui_angry-circle") // 나쁜 시야
        default: return Image("")
        }
    }
    
    // 날씨 아이콘
    private func weatherImage(for weather: String?) -> Image {
        guard let weather = weather else {
            return Image(systemName: "")
        }
        
        switch weather {
        case "맑음": return Image("sun")
        case "약간 흐림": return Image("cloud-sun")
        case "흐림": return Image("cloud")
        case "비": return Image("rain")
        default: return Image("")
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("환경정보")
                    .font(Font.omyu.regular(size: 16))
                    .foregroundStyle(status != .empty ? Color.bw_black : Color.grayscale_g400)
                if status == .partial {
                    Text("작성중")
                        .font(Font.NanumSquareNeo.NanumSquareNeoBold(size: 10))
                        .foregroundStyle(Color.role_color_nagative)
                        .padding(4)
                }
            }

            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    VStack(spacing: 4) {
                        Text("날씨")
                            .font(Font.omyu.regular(size: 16))
                            .foregroundStyle(environment?.weather != nil ? Color.grayscale_g700 : Color.grayscale_g400)
                            .padding(.bottom, 4)
                        weatherImage(for: environment?.weather)
                            .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundStyle(Color.primary_sea_blue)
                            .frame(width: 20)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity)

                    VerticalDashedDivider().frame(height: 72)

                    VStack{
                        Text("바람")
                            .font(Font.omyu.regular(size: 16))
                            .foregroundStyle(environment?.wind != nil ? Color.grayscale_g700 : Color.grayscale_g400)
                            .padding(.bottom, 8)
                        Text(environment?.wind ?? " ")
                            .font(Font.NanumSquareNeo.NanumSquareNeoBold(size: 12))
                            .foregroundStyle(Color.bw_black)
                    }
                    .frame(maxWidth: .infinity)

                    VerticalDashedDivider().frame(height: 72)

                    VStack(spacing: 4) {
                        Text("조류")
                            .font(Font.omyu.regular(size: 16))
                            .foregroundStyle(environment?.current != nil ? Color.grayscale_g700 : Color.grayscale_g400)
                            .padding(.bottom, 8)
                        Text(environment?.current ?? " ")
                            .font(Font.NanumSquareNeo.NanumSquareNeoBold(size: 12))
                            .foregroundStyle(Color.bw_black)
                    }
                    .frame(maxWidth: .infinity)

                    VerticalDashedDivider().frame(height: 72)

                    VStack(spacing: 4) {
                        Text("파도")
                            .font(Font.omyu.regular(size: 16))
                            .foregroundStyle(environment?.wave != nil ? Color.grayscale_g700 : Color.grayscale_g400)
                            .padding(.bottom, 8)
                        Text(environment?.wave ?? " ")
                            .font(Font.NanumSquareNeo.NanumSquareNeoBold(size: 12))
                            .foregroundStyle(Color.bw_black)
                    }
                    .frame(maxWidth: .infinity)
                }

                DashedDivider()

                HStack {
                    Spacer().frame(width: 32)
                    HStack() {
                        Text("기온")
                            .font(Font.omyu.regular(size: 16))
                            .foregroundStyle(environment?.airTemp != nil ? Color.grayscale_g700 : Color.grayscale_g400)
                            .padding(14)
                        Group{
                            Text(environment?.airTemp != nil ? "\(environment!.airTemp!)" : "0")
                                .font(Font.NanumSquareNeo.NanumSquareNeoBold(size: 14))
                            Text("℃")
                                .font(Font.NanumSquareNeo.NanumSquareNeoBold(size: 12))
                        }.foregroundStyle(environment?.airTemp != nil ? Color.bw_black : Color.grayscale_g400)
                    }
                    
                    Spacer()
                    
                    HStack() {
                        Text("수온")
                            .font(Font.omyu.regular(size: 16))
                            .foregroundStyle(environment?.waterTemp != nil ? Color.grayscale_g700 : Color.grayscale_g400)
                            .padding(14)
                        Group{
                            Text(environment?.waterTemp != nil ? "\(environment!.waterTemp!)" : "0")
                                .font(Font.NanumSquareNeo.NanumSquareNeoBold(size: 14))
                            Text("℃")
                                .font(Font.NanumSquareNeo.NanumSquareNeoBold(size: 12))
                        }.foregroundStyle(environment?.waterTemp != nil ? Color.bw_black : Color.grayscale_g400)
                    }
                    
                    Spacer()
                    
                    HStack() {
                        Text("시야")
                            .font(Font.omyu.regular(size: 16))
                            .foregroundStyle(environment?.visibility != nil ? Color.grayscale_g700 : Color.grayscale_g400)
                            .padding(14)
                        
                        visibilityImage(for: environment?.visibility)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundStyle(Color.primary_sea_blue)
                            .frame(width: 21)
                            
                    }
                    Spacer().frame(width: 32)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .stroke(Color.grayscale_g300)
            )
        }
    }
}

#Preview {
    DiveEnvironmentSection(
        environment: .constant(DiveEnvironment(
            weather: "맑음",
            wind: "중풍",
            current: "없음",
            wave: "약함",
            airTemp: 6,
            waterTemp: 6,
            visibility: "좋음"
        )),
        isSaved: .constant(false)
    )
    DiveEnvironmentSection(
        environment: .constant(DiveEnvironment(
            weather:  nil,
            wind:  nil,
            current:  nil,
            wave:  nil,
            airTemp:  nil,
            waterTemp:  nil,
            visibility: nil
        )),
        isSaved: .constant(false)
    )
}
