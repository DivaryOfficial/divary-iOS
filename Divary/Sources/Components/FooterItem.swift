//
//  FooterItem.swift
//  Divary
//
//  Created by 김나영 on 7/6/25.
//

import SwiftUI

struct FooterItem: View {
    let image: Image
    let title: String

    var body: some View {
        VStack(spacing: 4) {
            image
                .resizable()
                .frame(width: 40, height: 40)
                .padding(.bottom, 4)
            Text(title)
                .foregroundColor(.black)
        }
    }
}

#Preview {
    FooterItem(image: Image("tabler_photo-edit"), title: "꾸미기")
}
