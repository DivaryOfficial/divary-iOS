//
//  MyFriendView.swift
//  Divary
//
//  Created by 김나영 on 9/22/25.
//

import SwiftUI

struct MyFriendView: View {
    var onTapBell: () -> Void = {}
    
    var body: some View {
        VStack(alignment: .center) {
            MyPageTopBar(isMainView: false, title: "나의 친구", onBell: onTapBell)
            Spacer()
            Text("친구 기능 오픈 예정!")
                .font(Font.omyu.regular(size: 24))
                .foregroundStyle(Color.grayscale_g700)
                .padding()
            Text("조금만 기다리면,"+"\n"+"함께 다이빙 로그를 나눌 수 있어요 :)")
                .multilineTextAlignment(.center)
                .font(Font.NanumSquareNeo.NanumSquareNeoBold(size: 14))
                .foregroundStyle(Color.grayscale_g400)
                      
            Image("readyCharacter")
                .resizable()
                .frame(width: 200, height: 218)
                .scaledToFit()
            
            Spacer()
        }
    }
}

#Preview {
    MyFriendView()
}
