//
//  WeightPicker.swift
//  IV Drip
//
//  Created by Michael Mattesco Horta on 13/08/23.
//

import SwiftUI

struct WeightPicker: View {
    
    @State var showPickerWheel = false
    @State var inputTextField = "0"
    @State var inputInt: Int = 0
    
    @Binding var userInput: Int
    
    let buttonTapped: ()->()
    
    var body: some View {
        VStack {
            HStack (spacing: Constants.Layout.kPadding/2) {
                Text("Weight")
                    .font(.system(size: Constants.Layout.fontSize.inputRow.rawValue, weight: .bold))
                    .foregroundColor(Color("Text"))
                
                Spacer()
                
                Button {
                    withAnimation {
                        showPickerWheel.toggle()
                    }
                } label: {
                    Image(systemName: "plusminus.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 28)
                }
                
                TextField("Weight", text: $inputTextField)
                    .font(.system(size: 20))
                    .disabled(showPickerWheel)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.center)
                    .frame(width: 88, height: Constants.Layout.textFieldHeight)
                    .background(Color.white)
                    .cornerRadius(Constants.Layout.cornerRadius.small.rawValue)
                    .onTapGesture {
                        showPickerWheel = false
                    }
                    .onChange(of: inputTextField) { newValue in
                        inputInt = Int(newValue) ?? 0
                    }
                 
                Text("kg")
                    .font(.system(size: 14))
                    .frame(width: 80, alignment: .leading)
                
            }
            
            if showPickerWheel {
                IntWheelPicker(intCases: 3, selection: $inputInt, initialValue: inputInt)


                Button("OK") {
                    inputTextField = String(inputInt)
                    withAnimation {
                        showPickerWheel = false
                    }
                    buttonTapped()
                }
            }
                
            
        }
        .padding(Constants.Layout.kPadding/2)
        .background(Color("Row Background"))
        .cornerRadius(8)
        .onChange(of: inputInt) { newValue in
            inputTextField = String(newValue)
            userInput = newValue
        }
        
    }
}
