//
//  Error.swift
//  Divary
//
//  Created by 바견규 on 8/13/25.
//

import SwiftUI

// MARK: - 에러 오버레이
struct ErrorOverlay: View {
    let message: String
    let viewModel: CharacterViewModel
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.red)
                        
                        Text("오류 발생")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.red)
                        
                        Spacer()
                        
                        Button(action: {
                            viewModel.errorMessage = nil
                        }) {
                            Image(systemName: "xmark")
                                .foregroundStyle(.gray)
                        }
                    }
                    
                    Text(message)
                        .font(.system(size: 14))
                        .foregroundStyle(.black)
                        .multilineTextAlignment(.leading)
                    
                    HStack {
                        Button("다시 시도") {
                            viewModel.errorMessage = nil
                            viewModel.saveAvatarToServer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.primary_sea_blue)
                        .foregroundStyle(.white)
                        .cornerRadius(8)
                        
                        Spacer()
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .shadow(radius: 8)
                )
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
        .transition(.move(edge: .bottom))
        .animation(.easeInOut(duration: 0.3), value: viewModel.errorMessage)
    }
}
