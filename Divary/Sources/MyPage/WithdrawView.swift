//
//  WithdrawView.swift
//  Divary
//
//  Created by 김나영 on 11/6/25.
//

import SwiftUI

struct WithdrawView: View {
    var onTapBell: () -> Void = {}
    
    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            Text("그동안 함께해주셔서 감사합니다.")
                .font(Font.omyu.regular(size: 24))
                .foregroundStyle(Color.grayscale_g700)
                .padding()
            Text("탈퇴가 완료되었습니다.")
                .multilineTextAlignment(.center)
                .font(Font.NanumSquareNeo.NanumSquareNeoBold(size: 14))
                .foregroundStyle(Color.grayscale_g400)
                      
            Image("readyCharacter")
                .resizable()
                .frame(width: 200, height: 218)
                .scaledToFit()
            
            Spacer()
            
            Button(action: {
                print("확인")
            }) {
                Text("확인")
                    .font(.omyu.regular(size: 20))
                    .frame(maxWidth: .infinity, minHeight: 48)
                    .foregroundStyle(.white)
                    .background(Color.primary_sea_blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    WithdrawView()
}
