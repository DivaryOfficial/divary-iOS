//
//  SwiftUIView.swift
//  Divary
//
//  Created by 바견규 on 7/9/25.
//

import SwiftUI

struct DiveParticipantsSection: View {
    let participants: DiveParticipants?
    
    var status: SectionStatus {
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
                    .font(.headline)
                if status == .partial {
                    Text("작성중")
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(4)
                }
            }
            
            VStack(spacing: 0) {
                HStack {
                    Text("리더")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    Spacer()
                    Text(participants?.leader ?? " ")
                        .font(.system(size: 12))
                }
                .padding(8)
                
                DashedDivider()
                
                HStack {
                    Text("버디")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    Spacer()
                    Text(participants?.buddy ?? " ")
                        .font(.system(size: 12))
                }
                .padding(8)
                
                DashedDivider()
                
                HStack {
                    Text("동행자")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    Spacer()
                    Text((participants?.companion ?? []).joined(separator: ", "))
                        .font(.system(size: 12))
                }
                .padding(8)
            }
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .stroke(Color.gray, lineWidth: 1)
            )
        }
    }
}

#Preview {
    DiveParticipantsSection(
        participants: DiveParticipants(
            leader: "김리더",
            buddy: "박버디",
            companion: ["이동행", "최동행"]
        )
    )
}
