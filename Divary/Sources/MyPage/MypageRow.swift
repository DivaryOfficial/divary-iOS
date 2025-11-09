//
//  MypageRow.swift
//  Divary
//
//  Created by 바견규 on 11/9/25.
//

import SwiftUI

// MARK: - Component
struct MyPageRow: View {
    let icon: String
    let title: String
    var action: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: action) {
                HStack(spacing: 12) {
                    Image(icon)
                        .resizable()
                        .frame(width: 25, height: 25)
                    
                    Text(title)
                        .font(.omyu.regular(size: 20))
                        .foregroundStyle(.black)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color(.tertiaryLabel))
                }
                .padding(.vertical, 14)
            }
            Divider()
        }
    }
}

struct CustomerCenter: View {
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Image(.center)
                    .resizable()
                    .frame(width: 25, height: 25)
                
                VStack(alignment: .leading) {
                    Text("고객 센터")
                        .font(.omyu.regular(size: 20))
                        .foregroundStyle(.black)
                    Text(verbatim: "문의사항은 divary.app@gmail.com 으로 남겨주세요.")
                        .font(.omyu.regular(size: 16))
                        .foregroundStyle(Color(.grayscaleG400))
                }
                
                Spacer()
            }
            .padding(.vertical, 14)
            Divider()
        }
    }
}

struct AppCare: View {
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Image(.app)
                    .resizable()
                    .frame(width: 25, height: 25)
                Text("앱 관리")
                    .font(.omyu.regular(size: 20))
                    .foregroundStyle(.black)
                
                Spacer()
                Text("1.0.0")
                    .font(.omyu.regular(size: 16))
                    .foregroundStyle(Color(.grayscaleG400))
            }
            .padding(.vertical, 14)
            Divider()
        }
    }
}



