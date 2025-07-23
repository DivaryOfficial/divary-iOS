//
//  EnvironmentInputView.swift
//  Divary
//
//  Created by 바견규 on 7/17/25.
//

import SwiftUI

struct EnvironmentInputView: View {
    // 날씨 아이콘
    private func weatherImage(for weather: String?) -> Image {
        guard let weather = weather else {
            return Image(systemName: "")
        }
        
        switch weather {
        case "맑음": return Image("EnvInput-맑음")
        case "약간 흐림": return Image("EnvInput-약간흐림")
        case "흐림": return Image("EnvInput-흐림")
        case "비": return Image("EnvInput-비")
        default: return Image("")
        }
    }
    
    //바람 아이콘
    private func windImage(for wind: String?) -> Image {
        guard let wind = wind else {
            return Image(systemName: "")
        }
        
        switch wind {
        case "약풍": return Image("EnvInput-바람1")
        case "약풍-블루": return Image("EnvInput-바람1-블루")
        case "중풍": return Image("EnvInput-바람2")
        case "중풍-블루": return Image("EnvInput-바람2-블루")
        case "강풍": return Image("EnvInput-바람3")
        case "강풍-블루": return Image("EnvInput-바람3-블루")
        case "폭풍": return Image("EnvInput-바람4")
        case "폭풍-블루": return Image("EnvInput-바람4-블루")
        default: return Image("")
        }
    }
    
    //조류 아이콘
    private func currentImage(for current: String?) -> Image {
        guard let current = current else {
            return Image(systemName: "")
        }
        
        switch current {
        case "없음": return Image("EnvInput-없음")
        case "미류": return Image("EnvInput-조류1")
        case "중류": return Image("EnvInput-조류2")
        case "격류": return Image("EnvInput-조류3")
        default: return Image("")
        }
    }
    
    //파도 아이콘
    private func waveImage(for wave: String?) -> Image {
        guard let wave = wave else {
            return Image(systemName: "")
        }
        
        switch wave {
        case "약함": return Image("EnvInput-파도1")
        case "약함-블루": return Image("EnvInput-파도1-블루")
        case "중간": return Image("EnvInput-파도2")
        case "중간-블루": return Image("EnvInput-파도2-블루")
        case "강함": return Image("EnvInput-파도3")
        case "강함-블루": return Image("EnvInput-파도3-블루")
        default: return Image("")
        }
    }
    
    //체감 온도 아이콘
    private func feelsLikeTempImage(for temp: String?) -> Image {
        guard let temp = temp else {
            return Image(systemName: "")
        }
        
        switch temp {
        case "추움": return Image("EnvInput-추움")
        case "추움-블루": return Image("EnvInput-추움-블루")
        case "보통": return Image("EnvInput-templike-보통")
        case "보통-블루": return Image("EnvInput-templike-보통-블루")
        case "더움": return Image("EnvInput-더움")
        case "더움-블루": return Image("EnvInput-더움-블루")
        default: return Image("")
        }
    }
    
    // 시야 아이콘
    private func visibilityImage(for visibility: String?) -> Image {
        guard let visibility = visibility else {
            return Image(systemName: "")
        }
        
        switch visibility {
        case "좋음": return Image("EnvInput-좋음")   // 좋은 시야
        case "보통": return Image("EnvInput-보통")  // 보통 시야
        case "나쁨": return Image("EnvInput-나쁨") // 나쁜 시야
        default: return Image("")
        }
    }
    
    
    
    
    
    @Binding var environment: DiveEnvironment
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.gray.opacity(0.8)
                    .edgesIgnoringSafeArea(.all)
                
                VStack{
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            
                            // 날씨
                            Text("날씨")
                                .font(Font.omyu.regular(size: 20))
                            
                            IconButtonRow(
                                options: ["맑음", "약간 흐림", "흐림", "비"],
                                selected: environment.weather,
                                imageProvider: weatherImage(for:),
                                onSelect: { environment.weather = $0 },
                                size: 30
                            )
                            
                            // 바람
                            Text("바람")
                                .font(Font.omyu.regular(size: 20))
                            
                            IconButtonRow(
                                options: ["약풍", "중풍", "강풍", "폭풍"],
                                selected: environment.wind,
                                imageProvider: windImage(for:),
                                onSelect: { environment.wind = $0 },
                                size: 30,
                                isImage: true
                            )
                            
                            // 조류
                            Text("조류")
                                .font(Font.omyu.regular(size: 20))
                            
                            IconButtonRow(
                                options: ["없음", "미류", "중류", "격류"],
                                selected: environment.current,
                                imageProvider: currentImage(for:),
                                onSelect: { environment.current = $0 },
                                size: 30
                            )
                            
                            // 파도
                            Text("파도")
                                .font(Font.omyu.regular(size: 20))
                            
                            IconButtonRow(
                                options: ["약함", "중간", "강함"],
                                selected: environment.wave,
                                imageProvider: waveImage(for:),
                                onSelect: { environment.wave = $0 },
                                size: 45,
                                isImage: true
                            )
                            
                            // 기온
                            TemperatureInputField(
                                title: "기온",
                                placeholder: "0",
                                unit: "°C",
                                value: $environment.airTemp
                            )
                            
                            // 체감 온도
                            IconButtonRow(
                                options: ["추움", "보통", "더움"],
                                selected: environment.feelsLike,
                                imageProvider: feelsLikeTempImage(for:),
                                onSelect: { environment.feelsLike = $0 },
                                size: 45,
                                isImage: true
                            )
                            
                            
                            //수온
                            TemperatureInputField(
                                title: "수온",
                                placeholder: "0",
                                unit: "°C",
                                value: $environment.waterTemp
                            )
                            
                            // 시야
                            Text("시야")
                                .font(Font.omyu.regular(size: 20))
                            
                            IconButtonRow(
                                options: ["좋음", "보통", "나쁨"],
                                selected: environment.visibility,
                                imageProvider: visibilityImage(for:),
                                onSelect: { environment.visibility = $0 },
                                size: 45
                            )
                            
                        }
                        
                        
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 22)
                    .padding(.bottom, 22)
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
}

struct IconButtonRow: View {
    let options: [String]
    let selected: String?
    let imageProvider: (String?) -> Image
    let onSelect: (String) -> Void
    let size: CGFloat
    var isImage: Bool = false
    
    var body: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: options.count)
        
        LazyVGrid(columns: columns) {
            ForEach(options, id: \.self) { option in
                Button(action: {
                    onSelect(option)
                }) {
                    VStack() {
                        
                        Spacer()
                        
                        if isImage {
                            imageProvider(selected == option ? option + "-블루" : option)
                                .resizable()
                                .scaledToFit()
                                .frame(width: size, height: size)
                        }else {
                            imageProvider(option)
                                .resizable()
                                .scaledToFit()
                                .frame(width: size, height: size)
                        }
                            
                        Spacer()
                        
                        Text(option)
                            .font(Font.NanumSquareNeo.NanumSquareNeoBold(size: 9))
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity)
                    .aspectRatio(1, contentMode: .fit) // 정사각형 유지
                    .background(
                        RoundedRectangle(cornerRadius: 5.81)
                            .stroke(
                                selected == option ? Color.primary_sea_blue : Color.grayscale_g300
                            )
                    )
                    .foregroundStyle(selected == option ? Color.primary_sea_blue : Color.grayscale_g400)
                }
                .padding(.horizontal, 3)
                
            }
        }
    }
}

struct TemperatureInputField: View {
    let title: String
    let placeholder: String
    let unit: String
    @Binding var value: Int?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(Font.omyu.regular(size: 20))
            
            HStack {
                TextField(placeholder, text: Binding(
                    get: {
                        if let value = value {
                            return String(value)
                        } else {
                            return ""
                        }
                    },
                    set: {
                        if let intValue = Int($0) {
                            value = intValue
                        } else {
                            value = nil
                        }
                    }
                ))
                .font(Font.NanumSquareNeo.NanumSquareNeoBold(size: 12))
                .keyboardType(.numberPad)
                .foregroundColor(Color.bw_black)
                
                Spacer()
                
                Text(unit)
                    .foregroundColor(Color.bw_black)
                    .font(Font.NanumSquareNeo.NanumSquareNeoBold(size: 14))
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .background(Color.grayscale_g100)
            .cornerRadius(8)
        }
    }
}





#Preview {
    @Previewable @State var previewEnv = DiveEnvironment(
        weather: "맑음",
        wind: "약풍",
        current: "없음",
        wave: "약함",
        airTemp: nil,
        feelsLike: nil,
        waterTemp: nil,
        visibility: "보통"
    )
    
    return EnvironmentInputView(environment: $previewEnv)
}
