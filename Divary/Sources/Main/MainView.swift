//
//  MainView.swift
//  Divary
//
//  Created by 김나영 on 7/31/25.
//

import SwiftUI

struct MainView: View {
    @State private var selectedYear: Int = 2025
    
    private var canSubYear: Bool {
        selectedYear > 1950
    }
    private var canAddYear: Bool {
        selectedYear < 2025
    }
    
    var body: some View {
        ZStack {
            background
            yearSelectbar
            YearlyLogBubble()
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
            .padding(.bottom, 3)
            
            HStack(alignment: .top) {
                Button(action: {
                    if canSubYear {
                        selectedYear -= 1
                    }
                }) {
                    Image("chevron.left")
                        .foregroundStyle(canSubYear ? .black : Color(.grayscaleG500))
                }
                .padding(.top, 8)
                Spacer()
                
                YearDropdownPicker(selectedYear: $selectedYear)
                
                Spacer()
                Button(action: {
                    if canAddYear {
                        selectedYear += 1
                    }
                }) {
                    Image("chevron.right")
                        .foregroundStyle(canAddYear ? .black : Color(.grayscaleG500))
                }
                .padding(.top, 8)
            }
            .padding(.horizontal, 12)
            
            Spacer()
        }
    }
}

#Preview {
    MainView()
}
