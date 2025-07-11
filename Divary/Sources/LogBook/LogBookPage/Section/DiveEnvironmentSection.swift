//
//  SwiftUIView.swift
//  Divary
//
//  Created by 바견규 on 7/9/25.
//

import SwiftUI

struct DiveEnvironmentSection: View {
    let environment: DiveEnvironment?

    var status: SectionStatus {
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

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("환경정보")
                    .font(.headline)
                if status == .partial {
                    Text("작성중")
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(4)
                }
            }

            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    VStack(spacing: 4) {
                        Text("날씨")
                            .font(.caption)
                        Text(environment?.weather ?? " ")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)

                    VerticalDashedDivider().frame(height: 72)

                    VStack{
                        Text("바람")
                            .font(.caption)
                        Text(environment?.wind ?? " ")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)

                    VerticalDashedDivider().frame(height: 72)

                    VStack(spacing: 4) {
                        Text("조류")
                            .font(.caption)
                        Text(environment?.current ?? " ")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)

                    VerticalDashedDivider().frame(height: 72)

                    VStack(spacing: 4) {
                        Text("파도")
                            .font(.caption)
                        Text(environment?.wave ?? " ")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                }

                DashedDivider()

                HStack {
                    HStack() {
                        Text("기온")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding()
                        Text(environment?.airTemp != nil ? "\(environment!.airTemp!)" : "0")
                            .font(.body)
                        Text("℃")
                    }
                    
                    Spacer()
                    
                    HStack() {
                        Text("수온")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding()
                        Text(environment?.waterTemp != nil ? "\(environment!.waterTemp!)" : "0")
                            .font(.body)
                        Text("℃")
                    }
                    
                    Spacer()
                    
                    HStack() {
                        Text("시야")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Text(environment?.visibility ?? " ")
                            .font(.body)
                            .padding(.horizontal)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .stroke(Color.gray.opacity(0.4), lineWidth: 1)
            )
        }
    }
}

#Preview {
    DiveEnvironmentSection(
        environment: DiveEnvironment(
            weather: "맑음",
            wind: "중풍",
            current: "없음",
            wave: "약함",
            airTemp: 6,
            waterTemp: 6,
            visibility: "😊"
        )
    )
}
