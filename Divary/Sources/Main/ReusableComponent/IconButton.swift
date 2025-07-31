//
//  IconButton.swift
//  Divary
//
//  Created by chohaeun on 7/18/25.
//

import SwiftUI

struct IconButton: View {
    let options: [String]
    let selected: String?
    let imageProvider: (String?) -> Image
    let onSelect: (String) -> Void
    let size: CGFloat
    var isImage: Bool = false
    
    var body: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: options.count)
        
        LazyVGrid(columns: columns) {
            ForEach(options, id: \.self) { option in
                
                Button(action: {
                    onSelect(option)
                }) {
                    VStack(spacing: 4) {
                        
                        Spacer()
                        if isImage {
                            imageProvider(selected == option ? option + "B" : option)
                                .resizable()
                                .scaledToFit()
                                .frame(width: size, height: size)
                        }else {
                            imageProvider(option)
                                .resizable()
                                .scaledToFit()
                                .frame(width: size, height: size)
                        }
                        
                        Spacer()
                        
                        Text(option)
                            .font(Font.NanumSquareNeo.NanumSquareNeoRegular(size: 12))
                        
                        Spacer()
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity)
                    .aspectRatio(1, contentMode: .fit) // 정사각형 유지
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(
                                selected == option ? Color.primary_sea_blue : Color.grayscale_g300
                            )
                    )
                    .foregroundStyle(selected == option ? Color.primary_sea_blue : Color.grayscale_g300)
                }
                .padding(.horizontal, 3)
                
            }
        }
    }
}
