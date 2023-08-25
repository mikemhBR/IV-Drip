//
//  ValueInputRowView.swift
//  IV Drip
//
//  Created by Michael Mattesco Horta on 13/08/23.
//

import SwiftUI

struct DecimalInputRowView: View {
    let itemTitle: String
    let pickerIntCases: Int
    let pickerDecimalCases: Int
    
    @State var showPickerWheel = false
    @State var inputTextField = "0.0"
    @State var inputDouble = 0.0
    
    @Binding var userValue: Double
    
    @State private var concentrationOption: ConcentrationOptions = .mcgKgMin
    
    var body: some View {
        VStack {
            HStack (spacing: Constants.Layout.kPadding/2) {
                Text(itemTitle)
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
                
                TextField("Infusion Velocity", text: $inputTextField)
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
                        inputDouble = Double(newValue) ?? 0.0
                    }
                 
                Menu {
                    Picker("test", selection: $concentrationOption) {
                        ForEach(ConcentrationOptions.allCases, id: \.self) { option in
                            Text(option.rawValue)
                                .font(.system(size: 14))
                                
                        }
                    }
                } label: {
                    Text(concentrationOption.rawValue)
                        .fixedSize(horizontal: true, vertical: false)
                        .padding(Constants.Layout.kPadding/2)
                        .frame(height: 44)
                        .background(Color.blue.opacity(0.2))
                        .font(.system(size: 12))
                        .cornerRadius(Constants.Layout.kPadding/2)
                }

                
                
                
            }
            
            if showPickerWheel {
                DecimalWheelPicker(intCases: pickerIntCases, decimalCases: pickerDecimalCases, selection: $inputDouble, initialValue: inputDouble)
                    
                    
                Button("OK") {
                    inputTextField = String(format: "%.\(pickerDecimalCases)f", inputDouble)
                    withAnimation {
                        showPickerWheel = false
                    }
                }
            }
                
            
        }
        .padding(8)
        .background(Color("Row Background"))
        .cornerRadius(8)
        .onChange(of: inputDouble) { newValue in
            inputTextField = String(format: "%.\(pickerDecimalCases)f", newValue)
            userValue = newValue
        }
        
    }
}

struct ValueInputRowView_Previews: PreviewProvider {
    
    static var previews: some View {
        DecimalInputRowView(itemTitle: "Drug", pickerIntCases: 2, pickerDecimalCases: 2, userValue: .constant(0.0))
    }
}
