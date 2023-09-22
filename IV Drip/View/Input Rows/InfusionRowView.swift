//
//  InfusionRowView.swift
//  IV Drip
//
//  Created by Michael Mattesco Horta on 13/08/23.
//

import SwiftUI

struct InfusionRowView: View {
    let itemTitle: String
    let pickerIntCases: Int
    let pickerDecimalCases: Int
    
    @State var showPickerWheel = false
    @State var inputTextField = "0.0"
    @State var inputDouble = 0.0
    
    @Binding var userValue: Double
    @Binding var selectedInfusionOption: InfusionRateOptions
    
    @State private var infusionOptions: InfusionRateOptions = .mlHour
    
    @Binding var currentlySelectedRow: RowType?
    
    var rowTag: RowType = .volume
    
    let buttonTapped: ()->()
    
    var body: some View {
        VStack {
            HStack (spacing: Constants.Layout.kPadding/2) {
                Text(itemTitle)
                    .font(.system(size: Constants.Layout.fontSize.inputRow.rawValue, weight: .bold))
                    .foregroundColor(Color("Text"))
                    .fixedSize()
                
                Spacer()
                
                Button {
                    withAnimation {
                        currentlySelectedRow = rowTag
                        showPickerWheel.toggle()
                    }
                } label: {
                    Image(systemName: "plusminus.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 28, height: 28)
                }
                
                TextField("Infusion Velocity", text: $inputTextField, onEditingChanged: { isEditing in
                    if isEditing {
                        if Double(inputTextField) == 0.0 {
                            DispatchQueue.main.async {
                                inputTextField = ""
                            }
                        }
                    } else {
                        inputDouble = Double(inputTextField) ?? 0.0
                    }
                })
                    .modifier(InputRowTextFieldModifier())
                    .disabled(showPickerWheel)
                    .onTapGesture {
                        withAnimation{
                            showPickerWheel = false
                        }
                    }
                    .onSubmit {
                        inputDouble = Double(inputTextField) ?? 0.0
                    }
                 
                Menu {
                    Picker("test", selection: $infusionOptions) {
                        ForEach(InfusionRateOptions.allCases, id: \.self) { option in
                            Text(option.rawValue)
                                .font(.system(size: 14))
                                
                        }
                    }
                } label: {
                    Text(infusionOptions.rawValue)
                        .modifier(InputRowButtonModifier())
                }

                
                
                
            }
            
            if showPickerWheel {
                DecimalWheelPicker(intCases: pickerIntCases, decimalCases: pickerDecimalCases, selection: $inputDouble, initialValue: inputDouble)
                    
                    
                Button("OK") {
                    inputTextField = String(format: "%.\(pickerDecimalCases)f", inputDouble)
                    withAnimation {
                        showPickerWheel = false
                    }
                    buttonTapped()
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
        .onChange(of: infusionOptions) { newValue in
            selectedInfusionOption = newValue
        }
        
    }
}

struct InfusionRowView_Previews: PreviewProvider {
    static var previews: some View {
        InfusionRowView(itemTitle: "Test", pickerIntCases: 3, pickerDecimalCases: 1, userValue: .constant(0), selectedInfusionOption: .constant(.mlHour), currentlySelectedRow: .constant(.infusionVelocity)) {
            
        }
    }
}
