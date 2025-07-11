//
//  SwiftUIView.swift
//  Divary
//
//  Created by 바견규 on 7/9/25.
//

import SwiftUI

struct DiveOverviewSection: View {
    let overview: DiveOverview?
    var status: SectionStatus {
        let values = [overview?.title, overview?.point, overview?.purpose, overview?.method]
        if values.allSatisfy({ $0?.isEmpty ?? true }) {
            return .empty
        } else if values.allSatisfy({ !($0?.isEmpty ?? true) }) {
            return .complete
        } else {
            return .partial
        }
    }

    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("다이빙 개요")
                    .font(.headline)
                if status == .partial {
                    Text("작성중")
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(4)
                    
                }
            }
            VStack{
                HStack{
                    VStack(alignment: .leading, spacing: 4) {
                        Text("다이빙 지역")
                            .padding(.bottom, 10)
                        
                        HStack{
                            Spacer()
                            Text("\(overview?.title ?? " ")")
                        }
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("분류")
                            .padding(.bottom, 10)
                        
                        HStack{
                            Spacer()
                            Text("\(overview?.point ?? " ")")
                        }
                    }
                }
                .padding(.top, 10)
                .padding(.horizontal)
                
                DashedDivider()
                
                HStack{
                    VStack(alignment: .leading, spacing: 4) {
                        Text("다이빙 목적")
                            .padding(.bottom, 10)
                        
                        HStack{
                            Spacer()
                            Text("\(overview?.purpose ?? " ")")
                        }
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("다이빙 방법")
                            .padding(.bottom, 10)
                        
                        HStack{
                            Spacer()
                            Text("\(overview?.method ?? " ")")
                        }
                    }
                }
                .padding(.bottom, 10)
                .padding(.horizontal)
            }
            .cornerRadius(10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .stroke(Color.gray, lineWidth: 1)
            )
            
        }
    }
}

#Preview {
    DiveOverviewSection(
        overview: DiveOverview(
            title: "제주도 서귀포시",
            point: "문섬",
            purpose: "펀 다이빙",
            method: "보트"
        )
    )
}
