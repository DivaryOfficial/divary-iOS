//
//  OceanThemaStoreComponent.swift
//  Divary
//
//  Created by 바견규 on 7/26/25.
//

import SwiftUI

struct OceanThemaStoreComponent: View {
    let imgText: String
    let componentText: String
    let isSelected: Bool
    let onSelected: () -> Void

    var body: some View {
        Button(action: {
            onSelected()
        }) {
            VStack(spacing: 16) {
                ZStack {
                    Image(isSelected ? imgText + "Clicked" : imgText + "Default")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }

                HStack {
                    Text(componentText)
                        .font(Font.omyu.regular(size: 20))
                        .foregroundColor(.bw_black)
                    Spacer()
                }
            }
        }
    }
}



#Preview {
    OceanThemaStoreComponent(
        imgText: "CoralForestStore",
        componentText: "산호숲",
        isSelected: true, // 또는 false로 설정
        onSelected: {}
    )
}
