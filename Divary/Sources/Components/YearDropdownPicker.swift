//
//  YearDropdownPicker.swift
//  Divary
//
//  Created by 김나영 on 7/31/25.
//

import SwiftUI

struct YearDropdownPicker: View {
    @State private var selection = 2025
    @State private var isExpanded = false

    var body: some View {
        dropDown
    }
    
    private var dropDown: some View {
        VStack(spacing: 0) {
            // 선택된 항목 버튼
            Button(action: {
                withAnimation {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text("\(String(selection))년")
                        .font(Font.omyu.regular(size: 20))
                        .foregroundColor(.black)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.black)
                        .font(.system(size: 14, weight: .bold))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
            }
            
            // 드롭다운 메뉴
            if isExpanded {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach((1950...2025).reversed(), id: \.self) { item in
                            Button(action: {
                                selection = item
                                isExpanded = false
                            }) {
                                Text("\(String(item))년")
                                    .font(Font.omyu.regular(size: 20))
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(selection == item ? Color.gray.opacity(0.15) : Color.white)
                            }
                        }
                    }
                }
                .frame(height: 150) // 5개만 보이도록
                .background(Color.white)
            }
        }
        .frame(width: 110)
        .background(.clear)
        .cornerRadius(12)
    }
}

#Preview {
    YearDropdownPicker()
}
