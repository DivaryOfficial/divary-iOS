//
//  SwiftUIView.swift
//  Divary
//
//  Created by 바견규 on 7/9/25.
//

import SwiftUI

struct DiveEquipmentSection: View {
    @Binding var equipment: DiveEquipment?
    @Binding var isSaved: Bool
    
    var status: SectionStatus {
        if isSaved { // 사용자가 저장했으면 무조건 .complete
            return .complete
        }
        
        let suit = equipment?.suitType
        let items = equipment?.Equipment
        let weight = equipment?.weight

        let isSuitEmpty = suit?.isEmpty ?? true
        let isItemsEmpty = items?.isEmpty ?? true
        let isWeightEmpty = weight == nil

        if isSuitEmpty && isItemsEmpty && isWeightEmpty {
            return .empty
        } else if !isSuitEmpty && !isItemsEmpty && !isWeightEmpty {
            return .complete
        } else {
            return .partial
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("착용")
                    .font(Font.omyu.regular(size: 16))
                    .foregroundStyle(status != .empty ? Color.bw_black : Color.grayscale_g400)
                if status == .partial {
                    Text("작성중")
                        .font(Font.NanumSquareNeo.NanumSquareNeoRegular(size: 10))
                        .foregroundStyle(Color.role_color_nagative)
                        .padding(4)
                }
            }

            VStack(spacing: 0) {
                equipmentRow(title: "슈트 종류", value: equipment?.suitType)
                DashedDivider()

                equipmentRow(title: "착용", value: (equipment?.Equipment ?? [" "]).joined(separator: ", "))
                DashedDivider()

                equipmentRow(title: "웨이트", value: equipment?.weight.map { "\($0)" }, unit: "kg")
            }
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .stroke(Color.grayscale_g300)
            )
        }
    }

    private func equipmentRow(title: String, value: String?, unit: String? = nil) -> some View {
        let trimmedValue = value?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let isEmpty = trimmedValue.isEmpty

        return HStack(alignment: .top) {
            Text(title)
                .foregroundStyle(isEmpty ? Color.grayscale_g400 : Color.grayscale_g700)
                .font(Font.omyu.regular(size: 14))

            Spacer()

            HStack(alignment: .bottom, spacing: 2) {
                Text(isEmpty ? " " : trimmedValue)
                    .foregroundStyle(isEmpty ? Color.grayscale_g400 : Color.bw_black)
                    .font(Font.NanumSquareNeo.NanumSquareNeoRegular(size: 12))

                if let unit = unit {
                    Text(unit)
                        .foregroundStyle(isEmpty ? Color.grayscale_g400 : Color.bw_black)
                        .font(Font.NanumSquareNeo.NanumSquareNeoRegular(size: 12))
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            .multilineTextAlignment(.trailing)
            .frame(maxWidth: .infinity, alignment: .topTrailing)
        }
        .padding(8)
    }



}

#Preview {
    DiveEquipmentSection(
        equipment: .constant(DiveEquipment(
            suitType: "웻슈트 3mm",
            Equipment: ["BCD", "레귤레이터", "마스크", "핀", "스노클", "장갑", "부츠", "후드", "다이브 컴퓨터"],
            weight: 6
        )),
        isSaved: .constant(false)
    )
    DiveEquipmentSection(
        equipment: .constant(DiveEquipment(
            suitType: nil,
            Equipment: nil,
            weight: nil
        )),
        isSaved: .constant(false)
    )
}


