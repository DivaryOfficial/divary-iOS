//
//  CategoryTabBar.swift
//  Divary
//
//  Created by 김나영 on 8/4/25.
//

import SwiftUI

struct CategoryTabBar: View {
    @Binding var selectedCategory: SeaCreatureCategory

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(SeaCreatureCategory.allCases) { category in
                    categoryButton(for: category)
                }
            }
            .padding(.horizontal, 16)
        }
    }

    @ViewBuilder
    private func categoryButton(for category: SeaCreatureCategory) -> some View {
        Button {
            withAnimation {
                selectedCategory = category
            }
        } label: {
            Text(category.rawValue)
                .font(.omyu.regular(size: 16))
                .foregroundColor(selectedCategory == category ? Color(.primarySeaBlue) : .black)
                .padding(.vertical, 8)
                .padding(.horizontal, 18)
                .background(
                    Group {
                        if selectedCategory == category {
                            Capsule()
                                .stroke(Color(.primarySeaBlue), lineWidth: 1)
                        } else {
                            Capsule()
                                .fill(Color(.grayscaleG100))
                        }
                    }
                )
        }
    }
}

#Preview {
    @Previewable @State var selectedCategory: SeaCreatureCategory = .all
    CategoryTabBar(selectedCategory: $selectedCategory)
}
