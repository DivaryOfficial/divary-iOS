//
//  StoreNavBar.swift
//  Divary
//
//  Created by 바견규 on 7/26/25.
//

import SwiftUI

struct StoreNavBar: View {
    @Binding var showSheet: Bool

    var body: some View {
        ZStack{
            Text("상점")
                .font(Font.omyu.regular(size: 20))
                .foregroundStyle(Color.bw_black)
            
            HStack{
                Image("chevron.left")
                Spacer()
            }
        }
        .padding(12)
    }
}

#Preview {
    
    StoreNavBar(showSheet: .constant(true))
}
