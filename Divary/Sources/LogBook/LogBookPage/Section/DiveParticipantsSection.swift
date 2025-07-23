//
//  SwiftUIView.swift
//  Divary
//
//  Created by 바견규 on 7/9/25.
//

import SwiftUI

struct DiveParticipantsSection: View {
    @Binding var participants: DiveParticipants?
    @Binding var isSaved: Bool
    
    var status: SectionStatus {
        if isSaved { // 사용자가 저장했으면 무조건 .complete
            return .complete
        }
        
        let leader = participants?.leader?.isEmpty ?? true
        let buddy = participants?.buddy?.isEmpty ?? true
        let companions = participants?.companion?.allSatisfy { $0.isEmpty } ?? true
        
        if leader && buddy && companions {
            return .empty
        } else if !leader && !buddy && !(participants?.companion?.contains(where: { $0.isEmpty }) ?? false) {
            return .complete
        } else {
            return .partial
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("동행자")
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

                    equipmentRow(title: "리더", value: participants?.leader)

                
                DashedDivider()
                
                equipmentRow(title: "버디", value: participants?.buddy)
                
                DashedDivider()
                
                equipmentRow(title: "동행자",  value: (participants?.companion ?? [" "]).joined(separator: ", "))
            }
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .stroke(Color.grayscale_g300)
            )
        }
    }
        
    private func equipmentRow(title: String, value: String?) -> some View {
        let trimmedValue = value?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let isEmpty = trimmedValue.isEmpty

        return HStack(alignment: .top) {
            Text(title)
                .foregroundStyle(isEmpty ? Color.grayscale_g400 : Color.grayscale_g700)
                .font(Font.omyu.regular(size: 14))

            Spacer()

            HStack(alignment: .bottom, spacing: 2) {
                Text(isEmpty ? " " : trimmedValue)
                    .foregroundStyle(isEmpty ? Color.grayscale_g400 : Color.bw_black)
                    .font(Font.NanumSquareNeo.NanumSquareNeoBold(size: 12))
                    .lineSpacing(4)
            }
            .fixedSize(horizontal: false, vertical: true)
            .multilineTextAlignment(.trailing)
            .frame(maxWidth: .infinity, alignment: .topTrailing)
        }
        .padding(8)
    }

    
    
}

#Preview {
    VStack(spacing: 20) {
        DiveParticipantsSection(
            participants: .constant(DiveParticipants(
                leader: "김리더",
                buddy: nil,
                companion: ["이동행", "최동행"]
            )),
            isSaved: .constant(false)
        )

        DiveParticipantsSection(
            participants: .constant(DiveParticipants(
                leader: nil,
                buddy: nil,
                companion: nil
            )),
            isSaved: .constant(false)
        )
    }
    .padding()
}
