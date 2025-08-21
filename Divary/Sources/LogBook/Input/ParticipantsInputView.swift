//
//  ParticipantsInput.swift
//  Divary
//
//  Created by chohaeun on 7/18/25.
//

import SwiftUI

struct ParticipantsInputView: View {
    @Binding var participants: DiveParticipants
    
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
                            companion: $participants.companion
                        )
                        Spacer()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }
}

struct CompanionInputField: View {
    let title: String
    let placeholder: String
    @Binding var companion: [String]?
    @State private var inputText: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(Font.omyu.regular(size: 20))
            
            TextField(placeholder, text: $inputText)
                .font(Font.NanumSquareNeo.NanumSquareNeoRegular(size: 12))
                .foregroundStyle(Color.bw_black)
                .padding(.vertical, 12)
                .padding(.horizontal, 20)
                .background(Color.grayscale_g100)
                .cornerRadius(8)
                .onSubmit {
                    let companions = inputText
                        .components(separatedBy: CharacterSet(charactersIn: ", "))
                        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                        .filter { !$0.isEmpty }
                    
                    companion = companions.isEmpty ? nil : companions
                }
                .onAppear {
                    inputText = companion?.joined(separator: ", ") ?? ""
                }
                .onChange(of: companion) { _, newValue in
                    inputText = newValue?.joined(separator: ", ") ?? ""
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
