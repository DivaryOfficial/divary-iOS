//
//  ItemSelectionSection.swift
//  Divary
//
//  Created by 바견규 on 7/27/25.
//

import SwiftUI

 struct ItemSelectionSection<T: CaseIterable & RawRepresentable & Hashable>: View where T.RawValue == String {
        let title: String
        let items: [T]
        let selectedItem: T?
        let imageWidth: CGFloat
        let noneSize:CGFloat
        let noneHorizontalPadding: CGFloat
        let noneVerticalPadding: CGFloat
        let onSelect: (T) -> Void
        
        
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(Font.omyu.regular(size: 20))
                    .foregroundStyle(Color.bw_black)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(items, id: \.self) { type in
                            let isSelected = selectedItem == type

                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(isSelected ? Color.white : Color.grayscale_g100)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(isSelected ? Color.primary_sea_blue : Color.grayscale_g300, lineWidth: 1)
                                            .padding(1)
                                    )

                                if type.rawValue == "none" {
                                    Image("StoreNone")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundStyle(Color.grayscale_g400)
                                        .frame(width: noneSize)
                                        .padding(.horizontal, noneHorizontalPadding)
                                        .padding(.vertical, noneVerticalPadding)
                                } else {
                                    Image(type.rawValue)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: imageWidth)
                                        .padding(10)
                                }
                            }
                            .fixedSize()
                            .onTapGesture {
                                onSelect(type)
                            }
                            .animation(.spring(response: 0.3), value: isSelected)
                        }

                    }
                }
            }
        }
    }
