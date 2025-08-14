//
//  SwiftUIView.swift
//  Divary
//
//  Created by 바견규 on 7/9/25.
//
// DiveProfileSection.swift

import SwiftUI

struct DiveProfileSection: View {
    @Binding var profile: DiveProfile?
    @Binding var isSaved: Bool

    var status: SectionStatus {
        Self.getStatus(profile: profile, isSaved: isSaved)
    }
    
    // Static 메서드로 분리
    static func getStatus(profile: DiveProfile?, isSaved: Bool) -> SectionStatus {
        if isSaved { // 사용자가 저장했으면 무조건 .complete
            return .complete
        }
        
        let values: [Any?] = [
            profile?.diveTime,
            profile?.maxDepth,
            profile?.avgDepth,
            profile?.decoDepth,
            profile?.decoStop,
            profile?.startPressure,
            profile?.endPressure
        ]
        
        if values.allSatisfy({ $0 == nil }) {
            return .empty
        } else if values.allSatisfy({ $0 != nil }) {
            return .complete
        } else {
            return .partial
        }
    }
        

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("다이빙 프로파일")
                    .font(Font.omyu.regular(size: 16))
                    .foregroundStyle(status != .empty ? Color.bw_black : Color.grayscale_g400)
                // ✅ 완전저장된 상태에서는 "작성중" 표시하지 않음
                if status == .partial && !isSaved {
                    Text("작성중")
                        .font(Font.NanumSquareNeo.NanumSquareNeoBold(size: 10))
                        .foregroundStyle(Color.role_color_nagative)
                        .padding(4)
                }
            }

            VStack(spacing: 0) {
                DiveTimeView(diveTime: profile?.diveTime, isSaved: isSaved)
                DiveDepthInfoView(profile: profile, isSaved: isSaved)
                DashedDivider(color: (profile?.diveTime != nil || isSaved) ? Color.primary_sea_blue : Color.grayscale_g300)
                TankPressureView(profile: profile, isSaved: isSaved)
                DashedDivider(color: (profile?.diveTime != nil || isSaved) ? Color.primary_sea_blue : Color.grayscale_g300)
                GasConsumptionView(start: profile?.startPressure, end: profile?.endPressure, isSaved: isSaved)
            }
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .stroke((profile?.diveTime != nil || isSaved) ? Color.primary_sea_blue : Color.gray.opacity(0.4), lineWidth: 1)
            )
        }
    }
}

// DiveTimeView.swift
struct DiveTimeView: View {
    let diveTime: Int?
    let isSaved: Bool

    var body: some View {
        HStack {
            Text("Dive Time")
                .font(Font.omyu.regular(size: 24))
                .foregroundStyle(.white)
            Spacer()
            Text("\(diveTime ?? 0)")
                .font(Font.NanumSquareNeo.NanumSquareNeoBold(size: 16))
                .foregroundStyle(.white)
            Text("분")
                .font(Font.NanumSquareNeo.NanumSquareNeoBold(size: 14))
                .foregroundStyle(.white)
        }
        .padding()
        .background((diveTime != nil || isSaved) ? Color.primary_sea_blue : Color.grayscale_g400)
        .roundingCorner(8, corners: [.topLeft, .topRight])
    }
}


// DiveDepthInfoView.swift
struct DiveDepthInfoView: View {
    let profile: DiveProfile?
    let isSaved: Bool

    var body: some View {
        HStack {
            Image((profile?.maxDepth == nil && profile?.avgDepth == nil && profile?.decoStop == nil && !isSaved) ? "grayDiveGraph" : "blueDiveGraph")
                .frame(width: 165)
                .padding(.top, 12)

            VStack(alignment: .trailing, spacing: 4) {
                DepthRow(label: "최대수심", value: profile?.maxDepth, unit: "m", isSaved: isSaved)
                DepthRow(label: "평균수심", value: profile?.avgDepth, unit: "m", isSaved: isSaved)
                HStack {
                    DepthRow(label: "감압정지", value: profile?.decoDepth, unit: "m", isSaved: isSaved)
                    DepthRow(label: "", value: profile?.decoStop, unit: "분", isSaved: isSaved)
                }
            }
        }
        .padding()
    }
}

struct DepthRow: View {
    let label: String
    let value: Int?
    let unit: String
    let isSaved: Bool

    var body: some View {
        HStack {
            if !label.isEmpty {
                Text(label)
                    // ✅ 완전저장 시 항상 검정, 아니면 조건부
                    .foregroundStyle(isSaved ? Color.grayscale_g700 : (value != nil ? Color.grayscale_g700 : Color.grayscale_g400))
                    .font(Font.omyu.regular(size: 16))
            }
            Text("\(value ?? 0)")
                .font(Font.NanumSquareNeo.NanumSquareNeoBold(size: 14))
                // ✅ 완전저장 시 항상 검정, 아니면 조건부
                .foregroundStyle(isSaved ? Color.bw_black : (value != nil ? Color.bw_black : Color.grayscale_g400))
            Text(unit)
                .font(Font.NanumSquareNeo.NanumSquareNeoBold(size: 12))
                // ✅ 완전저장 시 항상 검정, 아니면 조건부
                .foregroundStyle(isSaved ? Color.bw_black : (value != nil ? Color.bw_black : Color.grayscale_g400))
        }
        .padding(.vertical, 4)
    }
}

// TankPressureView.swift
struct TankPressureView: View {
    let profile: DiveProfile?
    let isSaved: Bool

    var body: some View {
        HStack(spacing: 20) {
            TankView(
                title: "시작탱크 압력",
                imageName: (profile?.startPressure != nil || isSaved) ? "blueTankHigh" : "grayTankHigh",
                pressure: profile?.startPressure,
                isSaved: isSaved
            )
            TankView(
                title: "종료탱크 압력",
                imageName: (profile?.endPressure != nil || isSaved) ? "blueTankMiddle" : "grayTankMiddle",
                pressure: profile?.endPressure,
                isSaved: isSaved
            )
        }
        .padding(.vertical)
    }
}

struct TankView: View {
    let title: String
    let imageName: String
    let pressure: Int?
    let isSaved: Bool

    var body: some View {
        VStack {
            Text(title)
                .font(Font.omyu.regular(size: 18))

            Image(imageName)
                .frame(width: 80)

            (
                Text("\(pressure ?? 0)")
                    .font(Font.NanumSquareNeo.NanumSquareNeoBold(size: 14))
                +
                Text(" bar")
                    .font(Font.NanumSquareNeo.NanumSquareNeoBold(size: 12))
            )
        }
        // ✅ 완전저장 시 항상 검정, 아니면 조건부
        .foregroundStyle(isSaved ? Color.bw_black : (pressure != nil ? Color.bw_black : Color.grayscale_g400))
    }
}


// GasConsumptionView.swift
struct GasConsumptionView: View {
    let start: Int?
    let end: Int?
    let isSaved: Bool

    var body: some View {
        HStack {
            if let start = start, let end = end {
                    Text("기체 소모량 ")
                        .font(Font.omyu.regular(size: 16))
                        // ✅ 완전저장 시 항상 검정, 아니면 조건부
                        .foregroundStyle(isSaved ? Color.grayscale_g700 : Color.grayscale_g700)
                    
                    Text("\(max(start - end, 0))")
                        .font(Font.NanumSquareNeo.NanumSquareNeoBold(size: 14))
                        // ✅ 완전저장 시 항상 검정, 아니면 조건부
                        .foregroundStyle(isSaved ? Color.bw_black : Color.bw_black)
                    +
                    Text(" bar")
                        .font(Font.NanumSquareNeo.NanumSquareNeoBold(size: 12))
                        // ✅ 완전저장 시 항상 검정, 아니면 조건부
                        .foregroundStyle(isSaved ? Color.bw_black : Color.bw_black)
            } else {
                Text("기체 소모량 ")
                    .font(Font.omyu.regular(size: 16))
                    // ✅ 완전저장 시 항상 검정, 아니면 조건부
                    .foregroundStyle(isSaved ? Color.grayscale_g700 : Color.grayscale_g400)

                Text("0 bar")
                    .font(Font.NanumSquareNeo.NanumSquareNeoBold(size: 14))
                    // ✅ 완전저장 시 항상 검정, 아니면 조건부
                    .foregroundStyle(isSaved ? Color.bw_black : Color.grayscale_g400)
            }
            
        }
        .padding()
    }
}

//
//#Preview {
//        // 저장된 상태 (완전한 데이터)
//    DiveProfileSection(
//            profile: .constant(DiveProfile(
//                diveTime: 42,
//                maxDepth: 30,
//                avgDepth: 18,
//                decoStop: 3,
//                startPressure: 200,
//                endPressure: 50
//            )),
//            isSaved: .constant(false)
//        )
//
//        // 작성 안 된 상태 (빈 데이터)
//    DiveProfileSection(
//            profile: .constant(DiveProfile(
//                diveTime: nil,
//                maxDepth: nil,
//                avgDepth: nil,
//                decoStop: nil,
//                startPressure: nil,
//                endPressure: nil
//            )),
//            isSaved: .constant(false)
//        )
//}
