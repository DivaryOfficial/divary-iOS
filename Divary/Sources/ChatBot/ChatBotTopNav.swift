//
//  ChatBotNav.swift
//  Divary
//
//  Created by chohaeun on 8/6/25.
//
import SwiftUI

struct ChatBotTopNav: View {
    let onMenuTap: () -> Void
    
    var body: some View {
        HStack {
            Button(action: {}) {
                Image("chevron.left")
                    .foregroundStyle(Color.bw_black)
            }
            .padding(.top, 8)
            
            Spacer()
            
            Text("챗봇")
                .font(Font.omyu.regular(size: 20))
            
            Spacer()
            
            Button(action: onMenuTap) {
                Image(systemName: "line.3.horizontal")
                    .foregroundColor(.primary)
            }
        }
        .padding(12)
    }
}

#Preview {
    ChatBotTopNav(onMenuTap: {
        print("메뉴 버튼 클릭")
    })
}
