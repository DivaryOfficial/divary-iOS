//
//  ProfileInputView.swift
//  Divary
//
//  Created by chohaeun on 7/18/25.
//

import SwiftUI

struct ProfileInputView: View {
    
    //탱크 아이콘
    private func pressureImage(for pressure: String?) -> Image {
        guard let pressure = pressure else {
            return Image(systemName: "")
        }
        
        switch pressure {
        case "시작": return Image("starttank")
        case "시작B": return Image("starttankBlue")
        case "종료": return Image("endtank")
        case "종료B": return Image("endtankBlue")
        case "소모": return Image("anchor")
        case "소모B": return Image("anchorBlue")
        default: return Image("")
        }
    }
    
    @Binding var profile: DiveProfile

    var body: some View {
            ZStack {
                VStack{
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            
                            TemperatureInputField(
                                title: "Dive Time",
                                placeholder: "0",
                                unit: "분",
                                value: $profile.diveTime
                            )
                            
                            TemperatureInputField(
                                title: "최대 수심",
                                placeholder: "0",
                                unit: "m",
                                value: $profile.maxDepth
                            )
                            
                            TemperatureInputField(
                                title: "평균 수심",
                                placeholder: "0",
                                unit: "m",
                                value: $profile.avgDepth
                            )
                            
                            HStack{
                                
                                TemperatureInputField(
                                    title: "감압 정지",
                                    placeholder: "0",
                                    unit: "m",
                                    value: $profile.decoDepth
                                )
                                
                                TemperatureInputField(
                                    title: " ",
                                    placeholder: "0",
                                    unit: "분",
                                    value: $profile.decoStop
                                )
                            }
                            
                            HStack{
                                
                                PressInputField(
                                    title: "시작탱크 압력",
                                    placeholder: "0",
                                    unit: "Bar",
                                    value: $profile.startPressure,
                                    imageName: "starttank"
                                )
                            
                                Text("-").font(Font.omyu.regular(size: 20))
                                
                                PressInputField(
                                    title: "종료탱크 압력",
                                    placeholder: "0",
                                    unit: "Bar",
                                    value: $profile.endPressure,
                                    imageName: "endtank"
                                )
                                
                                Text("=").font(Font.omyu.regular(size: 20))
                                
                                PressInputField(
                                    title: "기체 소모량",
                                    placeholder: "0",
                                    unit: "Bar",
                                    value: .constant(calculateConsumption(start: profile.startPressure, end: profile.endPressure)),
                                    imageName: "contank"
                                )
                            }
                        }
                    }
//                    .padding(.horizontal, 11)
//                    .padding(.vertical, 22)
                    .frame(maxWidth: .infinity, alignment: .center)
                   // .padding(.horizontal)
                }
            }.onAppear {
                // 바인딩 강제 활성화 - 현재 값을 읽고 다시 설정
                let currentProfile = profile
                profile = currentProfile
            }
        }
    }

#Preview {
    
    @Previewable @State var preview = DiveProfile(
        
        diveTime: 6,
        maxDepth: 9,
        avgDepth: 3,
        decoStop: nil,
        startPressure: nil,
        endPressure: nil
    )
    
    ProfileInputView(profile: $preview)
    
}

struct PressInputField: View {
    let title: String
    let placeholder: String
    let unit: String
    @Binding var value: Int?
    let imageName: String   // ex: "starttank", "endtank", "usagetank"

    var body: some View {
        VStack(alignment: .center, spacing: 6) {
            Text(title)
                .font(Font.omyu.regular(size: 18))

            Image(value != nil ? "\(imageName)Blue" : imageName)

            HStack {
                if imageName == "contank" {
                    // 읽기 전용 (기체 소모량)
                    Text(value.map { String($0) } ?? "-")
                        .font(Font.NanumSquareNeo.NanumSquareNeoRegular(size: 12))
                        .foregroundStyle(Color.bw_black)
                } else {
                    // 입력 가능한 필드
                    TextField(placeholder, text: Binding(
                        get: { value.map(String.init) ?? "" },
                        set: { value = Int($0) }
                    ))
                    .font(Font.NanumSquareNeo.NanumSquareNeoRegular(size: 12))
                    .keyboardType(.numberPad)
                    .foregroundStyle(Color.bw_black)
                }

                Spacer()

                Text(unit)
                    .foregroundStyle(Color.bw_black)
                    .font(Font.NanumSquareNeo.NanumSquareNeoRegular(size: 12))
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .background(Color.grayscale_g100)
            .cornerRadius(8)
        }
    }
}

func calculateConsumption(start: Int?, end: Int?) -> Int? {
    guard let s = start, let e = end else { return nil }
    return s - e
}

