//
//  ParticipantsInput.swift
//  Divary
//
//  Created by chohaeun on 7/18/25.
//

import SwiftUI

struct ParticipantsInputView: View {
    @Binding var participants: DiveParticipants
    @FocusState private var focusedField: FocusedField?
    
    enum FocusedField {
        case leader, buddy, companion
    }
    
    var body: some View {
        ZStack {
            VStack{
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            Spacer()
                            // 리더
                            VStack(alignment: .leading, spacing: 6) {
                                Text("리더")
                                    .font(Font.omyu.regular(size: 20))
                                
                                TextField("김리더", text: Binding(
                                    get: { participants.leader ?? "" },
                                    set: { participants.leader = $0.isEmpty ? nil : $0 }
                                ))
                                .font(Font.NanumSquareNeo.NanumSquareNeoRegular(size: 12))
                                .foregroundStyle(Color.bw_black)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 20)
                                .background(Color.grayscale_g100)
                                .cornerRadius(8)
                                .focused($focusedField, equals: .leader)
                            }
                            .id("leader")
                            
                            // 버디
                            VStack(alignment: .leading, spacing: 6) {
                                Text("버디")
                                    .font(Font.omyu.regular(size: 20))
                                
                                TextField("김버디", text: Binding(
                                    get: { participants.buddy ?? "" },
                                    set: { participants.buddy = $0.isEmpty ? nil : $0 }
                                ))
                                .font(Font.NanumSquareNeo.NanumSquareNeoRegular(size: 12))
                                .foregroundStyle(Color.bw_black)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 20)
                                .background(Color.grayscale_g100)
                                .cornerRadius(8)
                                .focused($focusedField, equals: .buddy)
                            }
                            .id("buddy")
                            
                            // 동행자
                            CompanionInputField(
                                title: "동행자",
                                placeholder: "김동행, 박동행, 이동행",
                                companion: $participants.companion,
                                focused: $focusedField,
                                focusValue: .companion
                            )
                            .id("companion")
                            Spacer()
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
//        .task {
//            // 저장된 companion 값을 텍스트필드에 로드
//            if let companions = participants.companion {
//                companionInput = companions.joined(separator: ", git ")
//            }
//        }
    }
}

extension ParticipantsInputView.FocusedField {
    var scrollId: String {
        switch self {
        case .leader: return "leader"
        case .buddy: return "buddy"
        case .companion: return "companion"
        }
    }
}

struct CompanionInputField: View {
    let title: String
    let placeholder: String
    @Binding var companion: [String]?
    @State private var inputText: String = ""
    
    var focused: FocusState<ParticipantsInputView.FocusedField?>.Binding
    let focusValue: ParticipantsInputView.FocusedField
    
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
                .focused(focused, equals: focusValue)
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
