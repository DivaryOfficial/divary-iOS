//
//  TabSelector.swift
//  Divary
//
//  Created by 바견규 on 7/8/25.
//

import SwiftUI

struct TabSelector<T: Hashable & CaseIterable & RawRepresentable>: View where T.RawValue == String {
    @Binding var selectedTab: T

    var body: some View {
        let tabs = Array(T.allCases)

        HStack(spacing: 8) {
            ForEach(tabs, id: \.self) { tab in
                let isSelected = selectedTab == tab
                let foregroundColor = isSelected ? Color.white : Color.gray
                let backgroundColor = isSelected ? Color.blue : Color.gray.opacity(0.2)

                Button(action: {
                    selectedTab = tab
                }) {
                    Text(tab.rawValue)
                        .frame(maxWidth: .infinity)
                        .font(Font.omyu.regular(size: 20))
                        .padding(.vertical, 10)
                        .background(backgroundColor)
                        .foregroundColor(foregroundColor)
                        .clipShape(RoundedCorner(radius: 12, corners: [.topLeft, .topRight]))
                }
            }
        }
    }
}


#Preview {
    //@Previewable: 미리보기에서 동적 속성을 인라인으로 표시할 수 있는 태그
    @Previewable @State var selectedTab: DiveLogTab = .logbook
    TabSelector(selectedTab: $selectedTab)
}
