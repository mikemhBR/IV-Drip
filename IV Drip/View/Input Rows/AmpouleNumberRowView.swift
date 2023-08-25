//
//  AmpouleNumberRowView.swift
//  IV Drip
//
//  Created by Michael Mattesco Horta on 22/08/23.
//

import SwiftUI

struct AmpouleNumberRowView: View {
    @Binding var showPickerWheel: Bool
    @State var inputTextField = "1.0"
    @State var inputDouble: Double = 1.0
        
    @Binding var userInput: Double
    
    @Binding var currentlySelectedRow: RowType?
    
    var rowTag: RowType = .ampouleNumber
    
    let buttonTapped: ()->()
    
    var body: some View {
        VStack {
            HStack (spacing: Constants.Layout.kPadding/2) {
                Text("Ampoules")
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
                
                TextField("Ampoules", text: $inputTextField, onEditingChanged: { isEditing in
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
                    .font(.system(size: 16))
                    
                    .foregroundColor(Color("Text"))
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.center)
                    .frame(width: 72, height: Constants.Layout.textFieldHeight)
                    .background(Color.white)
                    .cornerRadius(Constants.Layout.cornerRadius.small.rawValue)
                    .disabled(showPickerWheel)
                    .onTapGesture {
                        withAnimation{
                            showPickerWheel = false
                        }
                    }
                    .onSubmit {
                        inputDouble = Double(inputTextField) ?? 0.0
                    }
                 
                
                HStack (spacing: 0) {
                    Button {
                        if inputDouble >= 1.0 {
                            inputDouble -= 1
                        }
                    } label: {
                        Image(systemName: "minus.rectangle.fill")
                    }
                    .font(.system(size: 20))
                    .frame(width: 48)
                    .foregroundColor(Color("Text").opacity(0.5))
                    
                    Button {
                        inputDouble += 1
                    } label: {
                        Image(systemName: "plus.rectangle.fill")
                    }
                    .frame(width: 48)
                    .font(.system(size: 20))
                    .foregroundColor(Color("Text").opacity(0.5))

                }
                
               
                
            }
            
            if showPickerWheel && currentlySelectedRow == rowTag {
                DecimalWheelPicker(intCases: 2, decimalCases: 1, selection: $inputDouble, initialValue: inputDouble)


                Button("OK") {
                    inputTextField = String(inputDouble)
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
        .onChange(of: inputDouble) { newValue in
            inputTextField = String(newValue)
            userInput = newValue
        }
        .onAppear {
            inputTextField = String(format: "%.1f", userInput)
        }
        
    }
}

struct AmpouleNumberRowView_Previews: PreviewProvider {
    static var previews: some View {
        AmpouleNumberRowView(showPickerWheel: .constant(false), userInput: .constant(80), currentlySelectedRow: .constant(.volume)) {
            
        }
    }
}
