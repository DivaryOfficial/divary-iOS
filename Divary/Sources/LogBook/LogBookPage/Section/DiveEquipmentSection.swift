//
//  SwiftUIView.swift
//  Divary
//
//  Created by 바견규 on 7/9/25.
//

import SwiftUI

struct DiveEquipmentSection: View {
    let equipment: DiveEquipment?

    var status: SectionStatus {
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
                    .font(.headline)
                if status == .partial {
                    Text("작성중")
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(4)
                }
            }

            VStack(spacing: 0) {
                HStack {
                    Text("슈트 종류")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    Spacer()
                    Text(equipment?.suitType ?? " ")
                        .font(.system(size: 12))
                }
                .padding(8)

                DashedDivider()

                HStack {
                    Text("착용")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    Spacer()
                    Text((equipment?.Equipment ?? [" "]).joined(separator: ", "))
                        .font(.system(size: 12))
                }
                .padding(8)

                DashedDivider()

                HStack {
                    Text("웨이트")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    Spacer()
                    if let weight = equipment?.weight {
                        Text("\(weight) kg")
                            .font(.system(size: 12))
                    } else {
                        Text(" kg")
                            .font(.system(size: 12))
                    }
                }
                .padding(8)
            }
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .stroke(Color.gray, lineWidth: 1)
            )
        }
    }
}


#Preview {
    DiveEquipmentSection(
        equipment: DiveEquipment(
            suitType: "웻슈트 3mm",
            Equipment: ["BCD", "레귤레이터", "마스크"],
            weight: 6
        )
    )
}
