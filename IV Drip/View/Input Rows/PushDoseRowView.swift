//
//  PushDoseRowView.swift
//  IV Drip
//
//  Created by Michael Mattesco Horta on 25/08/23.
//

import SwiftUI

struct PushDoseRowView: View {
    let itemTitle: String
    let pickerIntCases: Int
    let pickerDecimalCases: Int
    
    @Binding var showPickerWheel: Bool
    @State var inputTextField = "0.0"
    @State var inputDouble = 0.0
    
    @Binding var userValue: Double
    @Binding var selectedPushDoseOption: PushDoseOptions
    
    @State private var pushDoseOption: PushDoseOptions = .mgKg
    
    let isFinalField = false
    
    @Binding var currentlySelectedRow: RowType?
    
    let rowTag: RowType
    let buttonTapped: ()->()
    
    init(itemTitle: String, pickerIntCases: Int, pickerDecimalCases: Int, showPickerWheel: Binding<Bool>, inputTextField: String = "0.0", inputDouble: Double = 0.0, userValue: Binding<Double>, selectedPushDoseOption: Binding<PushDoseOptions>, pushDoseOption: PushDoseOptions = .mgKg, currentlySelectedRow: Binding<RowType?>, rowTag: RowType, buttonTapped: @escaping () -> Void) {
        self.itemTitle = itemTitle
        self.pickerIntCases = pickerIntCases
        self.pickerDecimalCases = pickerDecimalCases
        self._showPickerWheel = showPickerWheel
        self.inputTextField = inputTextField
        _inputDouble = State(initialValue: inputDouble)
        self._userValue = userValue
        self._selectedPushDoseOption = selectedPushDoseOption
        self._currentlySelectedRow = currentlySelectedRow
        self.rowTag = rowTag
        self.buttonTapped = buttonTapped
    }
    
    var body: some View {
        VStack {
            HStack (spacing: Constants.Layout.kPadding/2) {
                Text(itemTitle)
                    .font(.system(size: Constants.Layout.fontSize.inputRow.rawValue, weight: .bold))
                    .foregroundColor(Color("Text"))
                     
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
                        .frame(height: 28)
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
                    Picker("test", selection: $pushDoseOption) {
                        ForEach(PushDoseOptions.allCases, id: \.self) { option in
                            Text(option.rawValue)
                                .font(.system(size: 14))
                                
                        }
                    }
                } label: {
                    Text(pushDoseOption.rawValue)
                        .modifier(InputRowButtonModifier())
                }
                

                
                
                
            }
            
            if showPickerWheel && (currentlySelectedRow == rowTag) {
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
        .onChange(of: pushDoseOption) { newValue in
            selectedPushDoseOption = newValue
        }
        
    }
}
