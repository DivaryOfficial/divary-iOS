//
//  MyPageTopBar.swift
//  Divary
//
//  Created by 김나영 on 9/25/25.
//

import SwiftUI

struct MyPageTopBar: View {
    @Environment(\.diContainer) private var di
    
    let isMainView: Bool
    let title: String
    var onBell: () -> Void

    var body: some View {
        ZStack {
            Text(title)
                .font(.omyu.regular(size: 20))
                .foregroundStyle(.primary)

            HStack {
                if !isMainView {
                    Button {
                        di.router.pop()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.black)
                            .frame(width: 44, height: 44, alignment: .leading) // 터치 영역 확보
                            .contentShape(Rectangle())
                    }
                } else {
                    Color.clear.frame(width: 44, height: 44)
                }
                Spacer()
                Button(action: onBell) {
                    Image("bell-1")
                        .foregroundStyle(Color.black)
                        .padding(.horizontal, 2)
                        .contentShape(Rectangle())
                }
            }
        }
        .frame(height: 44)
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
}
//
//#Preview {
//    MyPageTopBar()
//}
