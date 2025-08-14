//
//  LocationSearchNavBar.swift
//  Divary
//
//  Created by 바견규 on 8/14/25.
//

import SwiftUI

struct LocationSearchNavBar: View {
    @Environment(\.diContainer) var container
    
    var body: some View {
        ZStack() {
            HStack{
                Button(action: {
                    container.router.pop()
                }) {
                    Image("chevron.left")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24)
                        .foregroundStyle(.black)
                }
                
                Spacer()
             
            }
            
            Text("스쿠버 다이빙 지역 검색")
                .font(Font.NanumSquareNeo.NanumSquareNeoBold(size: 14))
        }
        .padding(12)
        .background(Color.white)
    }

}



