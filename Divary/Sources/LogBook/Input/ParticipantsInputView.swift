//
//  ParticipantsInput.swift
//  Divary
//
//  Created by chohaeun on 7/18/25.
//

import SwiftUI

struct ParticipantsInputView: View {
    @Binding var participants: DiveParticipants
    @State private var companionInput: String? = nil
    
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
                        ListInputField(
                            title: "동행자",
                            placeholder: "김동행",
                            list: $participants.companion,
                            value: $companionInput
                        )
                        Spacer()
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

struct ListInputField: View {
    let title: String
    let placeholder: String
    @Binding var list: [String]?
    @Binding var value: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(Font.omyu.regular(size: 20))

            HStack {
                // 배경 박스
                HStack(spacing: 8) {
                    // 1. Placeholder
                    if (list?.isEmpty ?? true) && (value?.isEmpty ?? true) {
                        Text(placeholder)
                            .font(Font.NanumSquareNeo.NanumSquareNeoRegular(size: 12))
                            .foregroundStyle(.gray)
                    }

                    // 2. 사용자 입력된 companion
                    ForEach(list ?? [], id: \.self) { name in
                        Text(name)
                            .font(Font.NanumSquareNeo.NanumSquareNeoRegular(size: 12))
                            .foregroundStyle(Color.bw_black)
                    }

                    // 3. 입력창
                    TextField("", text: Binding(
                        get: { value ?? "" },
                        set: {
                            value = $0
                            handleInput($0)
                        }
                    ))
                    .font(Font.NanumSquareNeo.NanumSquareNeoRegular(size: 12))
                    .foregroundStyle(Color.bw_black)
                    .frame(minWidth: 40)
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 20)
                .background(Color.grayscale_g100)
                .cornerRadius(8)
            }
        }
    }

    private func handleInput(_ text: String) {
        let delimiters: [Character] = [",", " "]
        guard let lastChar = text.last, delimiters.contains(lastChar) else { return }

        let trimmed = text.dropLast().trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            if list == nil { list = [] }
            if !list!.contains(trimmed) {
                list?.append(trimmed)
            }
        }

        value = ""
    }
}
