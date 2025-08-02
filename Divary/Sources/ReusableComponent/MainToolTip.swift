//
//  MainToolTip.swift
//  Divary
//
//  Created by 김나영 on 8/2/25.
//

import SwiftUI

struct MainToolTip: View {
    enum ToolTipType {
        case plus
        case swipe

        var imageName: String {
            switch self {
            case .plus:
                return "plusTooltip"
            case .swipe:
                return "swipeTooltip"
            }
        }

        var message: String {
            switch self {
            case .plus:
                return "아직 바다 기록이 없어요.\n버튼을 눌러 첫 로그를 작성해보세요!"
            case .swipe:
                return "똑똑 누군가 있는 것 같아요..\n화면을 오른쪽으로 넘겨 확인해보세요."
            }
        }
    }

    let type: ToolTipType

    var body: some View {
        ZStack {
            Image(type.imageName)
//                .resizable()
//                .scaledToFit()
//                .frame(width: 140, height: 140)
            
            Text(type.message)
                .font(Font.NanumSquareNeo.NanumSquareNeoBold(size: 12))
                .foregroundStyle(.white)
        }
//        .padding()
//        .background(Color(.systemBackground))
//        .cornerRadius(12)
//        .shadow(radius: 4)
    }
}

#Preview {
    MainToolTip(type: .swipe)
    MainToolTip(type: .plus)
}
