//
//  ProfileInputView.swift
//  Divary
//
//  Created by chohaeun on 7/18/25.
//

import SwiftUI

struct ProfileInputView: View {
    
    @Binding var profile: DiveProfile
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.gray.opacity(0.8)
                    .edgesIgnoringSafeArea(.all)
                
                VStack{
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            
                            TemperatureInputField(
                                title: "Dive Time",
                                placeholder: "0",
                                unit: "°C",
                                value: $profile.diveTime
                            )
                            
                            TemperatureInputField(
                                title: "최대 수심",
                                placeholder: "0",
                                unit: "m",
                                value: $profile.maxDepth
                            )
                            
                            TemperatureInputField(
                                title: "평균 수심",
                                placeholder: "0",
                                unit: "m",
                                value: $profile.avgDepth
                            )
                            
                            
                            HStack{
                                
                                TemperatureInputField(
                                    title: "감압 정지",
                                    placeholder: "0",
                                    unit: "m",
                                    value: $profile.decoStop
                                )
                                
                                TemperatureInputField(
                                    title: " ",
                                    placeholder: "0",
                                    unit: "분",
                                    value: $profile.diveTime
                                )
                                
                            }

                        }
                        
                    }
                    .padding(.horizontal, 11)
                    .padding(.vertical, 22)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.white))
                            .stroke(Color.grayscale_g300)
                    )
                    .frame(maxHeight: geometry.size.height * 0.64)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal)
                    
                }
            }
        }
    }

}

#Preview {
    
    @Previewable @State var preview = DiveProfile(
        
        diveTime: 6,
        maxDepth: 9,
        avgDepth: 3,
        decoStop: nil,
        startPressure: nil,
        endPressure: nil
    )
    
    ProfileInputView(profile: $preview)
    
}
