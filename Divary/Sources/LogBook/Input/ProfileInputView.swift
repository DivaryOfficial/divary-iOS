//
//  ProfileInputView.swift
//  Divary
//
//  Created by chohaeun on 7/18/25.
//

import SwiftUI

struct ProfileInputView: View {
    
    @Binding var profile: DiveProfile
    @FocusState private var focusedField: FocusedField?
    
    enum FocusedField {
        case diveTime, maxDepth, avgDepth, decoDepth, decoStop, startPressure, endPressure
    }
    
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

    var body: some View {
        ZStack {
            VStack{
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            
                            ProfileTemperatureInputField(
                                title: "Dive Time",
                                placeholder: "0",
                                unit: "분",
                                value: $profile.diveTime,
                                focused: $focusedField,
                                focusValue: .diveTime
                            )
                            .id("diveTime")
                            
                            ProfileTemperatureInputField(
                                title: "최대 수심",
                                placeholder: "0",
                                unit: "m",
                                value: $profile.maxDepth,
                                focused: $focusedField,
                                focusValue: .maxDepth
                            )
                            .id("maxDepth")
                            
                            ProfileTemperatureInputField(
                                title: "평균 수심",
                                placeholder: "0",
                                unit: "m",
                                value: $profile.avgDepth,
                                focused: $focusedField,
                                focusValue: .avgDepth
                            )
                            .id("avgDepth")
                            
                            HStack{
                                
                                ProfileTemperatureInputField(
                                    title: "감압 정지",
                                    placeholder: "0",
                                    unit: "m",
                                    value: $profile.decoDepth,
                                    focused: $focusedField,
                                    focusValue: .decoDepth
                                )
                                .id("decoDepth")
                                
                                ProfileTemperatureInputField(
                                    title: " ",
                                    placeholder: "0",
                                    unit: "분",
                                    value: $profile.decoStop,
                                    focused: $focusedField,
                                    focusValue: .decoStop
                                )
                                .id("decoStop")
                            }
                            
                            HStack{
                                
                                PressInputField(
                                    title: "시작탱크 압력",
                                    placeholder: "0",
                                    unit: "Bar",
                                    value: $profile.startPressure,
                                    imageName: "starttank",
                                    focused: $focusedField,
                                    focusValue: .startPressure
                                )
                                .id("startPressure")
                            
                                Text("-").font(Font.omyu.regular(size: 20))
                                
                                PressInputField(
                                    title: "종료탱크 압력",
                                    placeholder: "0",
                                    unit: "Bar",
                                    value: $profile.endPressure,
                                    imageName: "endtank",
                                    focused: $focusedField,
                                    focusValue: .endPressure
                                )
                                .id("endPressure")
                                
                                Text("=").font(Font.omyu.regular(size: 20))
                                
                                // 🔥 기체 소모량은 자동 계산이므로 포커스 불필요
                                ReadOnlyPressField(
                                    title: "기체 소모량",
                                    unit: "Bar",
                                    value: .constant(calculateConsumption(start: profile.startPressure, end: profile.endPressure)),
                                    imageName: "contank"
                                )
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
}

extension ProfileInputView.FocusedField {
    var scrollId: String {
        switch self {
        case .diveTime: return "diveTime"
        case .maxDepth: return "maxDepth"
        case .avgDepth: return "avgDepth"
        case .decoDepth: return "decoDepth"
        case .decoStop: return "decoStop"
        case .startPressure: return "startPressure"
        case .endPressure: return "endPressure"
        }
    }
}

// ProfileInputView 전용 TemperatureInputField
struct ProfileTemperatureInputField: View {
    let title: String
    let placeholder: String
    let unit: String
    @Binding var value: Int?
    @FocusState.Binding var focused: ProfileInputView.FocusedField?
    let focusValue: ProfileInputView.FocusedField
    
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
                .foregroundStyle(Color.bw_black)
                .focused($focused, equals: focusValue)
                
                Spacer()
                
                Text(unit)
                    .foregroundStyle(Color.bw_black)
                    .font(Font.NanumSquareNeo.NanumSquareNeoBold(size: 14))
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .background(Color.grayscale_g100)
            .cornerRadius(8)
        }
    }
}

// 입력 가능한 압력 필드
struct PressInputField: View {
    let title: String
    let placeholder: String
    let unit: String
    @Binding var value: Int?
    let imageName: String
    @FocusState.Binding var focused: ProfileInputView.FocusedField?
    let focusValue: ProfileInputView.FocusedField

    var body: some View {
        VStack(alignment: .center, spacing: 6) {
            Text(title)
                .font(Font.omyu.regular(size: 18))

            Image(value != nil ? "\(imageName)Blue" : imageName)

            HStack {
                TextField(placeholder, text: Binding(
                    get: { value.map(String.init) ?? "" },
                    set: { value = Int($0) }
                ))
                .font(Font.NanumSquareNeo.NanumSquareNeoRegular(size: 12))
                .keyboardType(.numberPad)
                .foregroundStyle(Color.bw_black)
                .focused($focused, equals: focusValue)

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

// 🔥 읽기 전용 압력 필드 (기체 소모량용)
struct ReadOnlyPressField: View {
    let title: String
    let unit: String
    @Binding var value: Int?
    let imageName: String

    var body: some View {
        VStack(alignment: .center, spacing: 6) {
            Text(title)
                .font(Font.omyu.regular(size: 18))

            Image(value != nil ? "\(imageName)Blue" : imageName)

            HStack {
                Text(value.map { String($0) } ?? "-")
                    .font(Font.NanumSquareNeo.NanumSquareNeoRegular(size: 12))
                    .foregroundStyle(Color.bw_black)

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
