//
//  StoreNavBar.swift
//  Divary
//
//  Created by 바견규 on 7/26/25.
//

import SwiftUI

struct StoreNavBar: View {
    @Binding var showSheet: Bool
    @Environment(\.diContainer) private var container
    @Bindable var viewModel:CharacterViewModel
    
    var body: some View {
        ZStack{
            Text("상점")
                .font(Font.omyu.regular(size: 20))
                .foregroundStyle(Color.bw_black)
            
            HStack{
                Button(action: {
                    container.router.pop()
                    viewModel.saveAvatarToServer()
                }){
                    Image("chevron.left")
                        .foregroundStyle(Color.bw_black)
                }
                Spacer()
            }
        }
        .padding(12)
    }
}
