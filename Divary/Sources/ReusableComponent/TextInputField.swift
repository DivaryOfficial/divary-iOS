//
//  TextInputField.swift
//  Divary
//
//  Created by chohaeun on 7/18/25.
//

import SwiftUI

struct TextInputField: View {
    let title: String
    let placeholder: String
    let unit: String
    @Binding var value: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(Font.omyu.regular(size: 20))

            HStack {
                TextField(placeholder, text: Binding(
                    get: { value ?? "" },
                    set: { value = $0.isEmpty ? nil : $0 }
                ))
                .font(Font.NanumSquareNeo.NanumSquareNeoRegular(size: 12))
                .foregroundStyle(Color.bw_black)

                Spacer()

                Text(unit)
                    .foregroundStyle(Color.bw_black)
                    .font(Font.NanumSquareNeo.NanumSquareNeoRegular(size: 14))
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .background(Color.grayscale_g100)
            .cornerRadius(8)
        }
    }
}


struct LocationTextInputField: View {
    let title: String
    let placeholder: String
    let unit: String
    @Binding var value: String?
    @Environment(\.diContainer) var container
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(Font.omyu.regular(size: 20))
            
            HStack {
                TextField(placeholder, text: Binding(
                    get: { value ?? "" },
                    set: { newValue in
                        value = newValue.isEmpty ? nil : newValue
                    }
                ))
                .font(Font.NanumSquareNeo.NanumSquareNeoRegular(size: 12))
                .foregroundStyle(Color.bw_black)
                
                Spacer()
                
                Button(action: {
                    // 지역 검색 화면으로 이동
                    container.router.push(.locationSearch)
                }) {
                    if unit == "돋보기" {
                        Image("humbleicons_search")
                            .foregroundColor(Color.bw_black)
                            .font(.system(size: 16))
                    } else {
                        Text(unit)
                            .foregroundColor(Color.bw_black)
                            .font(.system(size: 16))
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    .background(Color(.systemGray6))
            )
        }
        .onReceive(container.router.$locationSearchText) { searchText in
            if !searchText.isEmpty {
                value = searchText
                // 검색 텍스트 초기화
                container.router.locationSearchText = ""
            }
        }
    }
}
