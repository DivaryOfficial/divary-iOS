//
//  SwiftUIView.swift
//  Divary
//
//  Created by 바견규 on 7/9/25.
//

import SwiftUI

struct DiveOverviewSection: View {
    @Binding var overview: DiveOverview?
    @Binding var isSaved: Bool
    
    var status: SectionStatus {
        Self.getStatus(overview: overview, isSaved: isSaved)
    }
    
    // Static 메서드로 분리
    static func getStatus(overview: DiveOverview?, isSaved: Bool) -> SectionStatus {
        if isSaved { // 사용자가 저장했으면 무조건 .complete
            return .complete
        }
        
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
            // 상단 타이틀
            HStack {
                Text("다이빙 개요")
                    .font(Font.omyu.regular(size: 16))
                    .foregroundStyle(status != .empty ? Color.bw_black : Color.grayscale_g400)
                if status == .partial && !isSaved {  // ✅ 추가
                    Text("작성중")
                        .font(Font.NanumSquareNeo.NanumSquareNeoBold(size: 10))
                        .foregroundStyle(Color.role_color_nagative)
                        .padding(4)
                }
            }

            VStack {
                // 상단 두 줄
                HStack {
                    overviewRow(title: "다이빙 지역", value: overview?.title)
                    
                    Spacer()
                    
                    overviewRow(title: "분류", value: overview?.point)
                }
                .padding(.top, 10)
                .padding(.bottom, 5)
                .padding(.horizontal, 15)

                DashedDivider()

                // 하단 두 줄
                HStack {
                    overviewRow(title: "다이빙 목적", value: overview?.purpose)
                    
                    Spacer()
                    
                    overviewRow(title: "다이빙 방법", value: overview?.method)
                }
                .padding(.top, 5)
                .padding(.bottom, 10)
                .padding(.horizontal, 15)
            }
            .cornerRadius(10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .stroke(Color.grayscale_g300)
            )
        }
    }

    /// 재사용 가능한 개요 항목 Row
    @ViewBuilder
    private func overviewRow(title: String, value: String?) -> some View {
        let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let isEmpty = trimmed.isEmpty

        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .foregroundStyle(isSaved ? Color.grayscale_g700 : (isEmpty ? Color.grayscale_g400 : Color.grayscale_g700))
                .font(Font.omyu.regular(size: 14))
                .padding(.bottom, 10)

            HStack {
                Spacer()
                Text(isEmpty ? " " : trimmed)
                    .font(Font.NanumSquareNeo.NanumSquareNeoBold(size: 12))
                    .foregroundStyle(isSaved ? Color.bw_black : (isEmpty ? Color.grayscale_g400 : Color.bw_black))
                    .multilineTextAlignment(.trailing)
            }
        }
    }
}


#Preview {
    DiveOverviewSection(
        overview: .constant(DiveOverview(
            title: "제주도 서귀포시",
            point: "문섬",
            purpose: "펀 다이빙",
            method: "보트"
        )),
        isSaved: .constant(false)
    )
}
