//
//  ParticipantsInput.swift
//  Divary
//
//  Created by chohaeun on 7/18/25.
//

import SwiftUI

struct ParticipantsInputView: View {
    @Binding var participants: DiveParticipants
    @State private var companionInput: String = ""
    
    var body: some View {
        ZStack {
            VStack{
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Spacer()
                        // 리더
                        TextInputField(
                            title: "리더",
                            placeholder: "김리더",
                            unit: "",
                            value: $participants.leader
                        )
                        
                        // 버디
                        TextInputField(
                            title: "버디",
                            placeholder: "김버디",
                            unit: "",
                            value: $participants.buddy
                        )
                        
                        // 동행자
                        CompanionInputField(
                            title: "동행자",
                            placeholder: "김동행, 박동행, 이동행",
                            value: $companionInput,
                            onCommit: {
                                participants.companion = parseCompanions(companionInput)
                            }
                        )
                        Spacer()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .task {
            // 저장된 companion 값을 텍스트필드에 로드
            if let companions = participants.companion {
                companionInput = companions.joined(separator: ", ")
            }
        }
    }
    
    private func parseCompanions(_ input: String) -> [String]? {
        let companions = input
            .components(separatedBy: CharacterSet(charactersIn: ", "))
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        return companions.isEmpty ? nil : companions
    }
}

struct CompanionInputField: View {
    let title: String
    let placeholder: String
    @Binding var value: String
    let onCommit: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(Font.omyu.regular(size: 20))
            
            TextField(placeholder, text: $value)
                .font(Font.NanumSquareNeo.NanumSquareNeoRegular(size: 12))
                .foregroundStyle(Color.bw_black)
                .padding(.vertical, 12)
                .padding(.horizontal, 20)
                .background(Color.grayscale_g100)
                .cornerRadius(8)
                .onSubmit {
                    onCommit()
                }
        }
    }
}

#Preview {
    @Previewable @State var previewParticipants = DiveParticipants(
        leader: "PMPM",
        buddy: "iOSiOS",
        companion: []
    )

    ParticipantsInputView(participants: $previewParticipants)
}
