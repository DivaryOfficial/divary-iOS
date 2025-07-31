//
//  MainView.swift
//  Divary
//
//  Created by 김나영 on 7/31/25.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        ZStack {
            background
            yearSelectbar
        }
    }
    
    private var background: some View {
        Image("seaBack")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
    }
    
    private var yearSelectbar: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {}) {
                    Image("bell-1")
                        .foregroundStyle(.black)
                }
                .padding(.trailing, 12)
                
            }
            .padding(.top, 50)
            
            HStack {
                Button(action: {}) {
                    Image("chevron.left")
                        .foregroundStyle(.black)
                }
                Spacer()
                
                YearDropdownPicker()
                
                Spacer()
                Button(action: {}) {
                    Image("chevron.right")
                        .foregroundStyle(.black)
                }
            }
            Spacer()
        }
    }
}

#Preview {
    MainView()
}
