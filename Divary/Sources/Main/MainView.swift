//
//  MainView.swift
//  Divary
//
//  Created by 김나영 on 7/31/25.
//

import SwiftUI

struct MainView: View {
    @State private var selectedYear: Int = 2025
    @State private var showSwipeTooltip = false
    @State private var showDeletePopup = false
    
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
            YearlyLogBubble(showDeletePopup: $showDeletePopup)
                .padding(.top, 150)
            
            if showSwipeTooltip {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Image(.swipeTooltip)
                            .padding(.trailing, 20)
                            .transition(.opacity)
                    }
                    .padding(.bottom, 200)
                }
            }

        }
        .task {
            // 최초 실행 시 한 번만 표시
            let launched = UserDefaults.standard.bool(forKey: "launchedBefore")
            if !launched {
                showSwipeTooltip = true
                UserDefaults.standard.set(true, forKey: "launchedBefore")
//        
//                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//                    withAnimation {
//                        showSwipeTooltip = false
//                    }
//                }
            }
        }
        .overlay {
           if showDeletePopup {
               DeletePopupView(isPresented: $showDeletePopup, deleteText: "삭제하시겠습니까?")
           }
       }
        
    }
    
    private var background: some View {
        Image("seaBack")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
    }
    
    private var yearSelectbar: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button(action: {}) {
                    Image("bell-1")
                        .foregroundStyle(.black)
                }
                .padding(.trailing, 12)
                
            }
//            .padding(.top, 50)
            .safeAreaInset(edge: .top) {
                Color.clear.frame(height: 55)
            }
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
