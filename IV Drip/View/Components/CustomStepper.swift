//
//  CustomStepper.swift
//  IV Drip
//
//  Created by Michael Mattesco Horta on 27/08/23.
//

import SwiftUI

struct CustomStepper: View {
    
    @Binding var inputDouble: Double
    
    let deleteTapped: () -> ()
    
    var body: some View {
        HStack (spacing: 0) {
            if inputDouble < 0.1 {
                Button {
                    deleteTapped()
                } label: {
                    Image(systemName: "trash.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(Color("Accent Red"))
                        
                }
                .frame(width: 48)
                
            } else {
                Button {
                    if inputDouble >= 1.0 {
                        inputDouble -= 1
                    }
                } label: {
                    Image(systemName: "minus.rectangle.fill")
                        .font(.system(size: 32))
                }
                .frame(width: 48)
                .foregroundColor(Color("Text").opacity(0.5))
            }
            
            
            Button {
                inputDouble += 1
            } label: {
                Image(systemName: "plus.rectangle.fill")
                    .font(.system(size: 32))
            }
            .frame(width: 48)
            
            .foregroundColor(Color("Text").opacity(0.5))

        }
    }
}

struct CustomStepper_Previews: PreviewProvider {
    static var previews: some View {
        CustomStepper(inputDouble: .constant(0.0)) {
            
        }
    }
}
