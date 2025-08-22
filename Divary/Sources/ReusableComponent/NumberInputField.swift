//
//  NumberInputField.swift
//  Divary
//
//  Created by chohaeun on 7/18/25.
//
import SwiftUI


// EquipmentInputView용 NumberInputField
struct NumberInputField: View {
    let title: String
    let placeholder: String
    let unit: String
    @Binding var value: Int?
    var focused: FocusState<EquipmentInputView.FocusedField?>.Binding
    let focusValue: EquipmentInputView.FocusedField
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(Font.omyu.regular(size: 20))
            
            HStack {
                TextField(placeholder, text: Binding(
                    get: {
                        if let value = value {
                            return String(value)
                        } else {
                            return ""
                        }
                    },
                    set: {
                        if let intValue = Int($0) {
                            value = intValue
                        } else {
                            value = nil
                        }
                    }
                ))
                .font(Font.NanumSquareNeo.NanumSquareNeoRegular(size: 12))
                .keyboardType(.numberPad)
                .foregroundStyle(Color.bw_black)
                .focused(focused, equals: focusValue)
                
                Spacer()
                
                Text(unit)
                    .foregroundStyle(Color.bw_black)
                    .font(Font.NanumSquareNeo.NanumSquareNeoRegular(size: 14))
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .background(Color.grayscale_g100)
            .cornerRadius(8)
        }
    }
}
