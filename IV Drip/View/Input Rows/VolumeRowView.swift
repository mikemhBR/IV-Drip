//
//  VolumeRowView.swift
//  IV Drip
//
//  Created by Michael Mattesco Horta on 13/08/23.
//

import SwiftUI

struct VolumeRowView: View {
    var rowTitle = "Volume"
    
    @Binding var showPickerWheel: Bool
    @State var inputTextField = "0.0"
    @State var inputDouble: Double
        
    @Binding var outputValue: Double
    
    @Binding var currentlySelectedRow: RowType?
    
    let rowTag: RowType
    
    let buttonTapped: ()->()
    
    var body: some View {
        VStack {
            HStack (spacing: Constants.Layout.kPadding/2) {
                Text(rowTitle)
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
                
                TextField("Volume", text: $inputTextField, onEditingChanged: { isEditing in
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
                 
                Text("ml")
                    .font(.system(size: 14))
                    .frame(width: 80)
                
            }
            
            if showPickerWheel && currentlySelectedRow == rowTag {
                DecimalWheelPicker(intCases: 4, decimalCases: 1, selection: $inputDouble, initialValue: inputDouble)


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
            outputValue = newValue
        }
        .onAppear {
            inputTextField = String(inputDouble)
        }
        
    }
}

struct VolumeRowView_Previews: PreviewProvider {
    static var previews: some View {
        VolumeRowView(showPickerWheel: .constant(false), inputDouble: 0.0, outputValue: .constant(80), currentlySelectedRow: .constant(.volume), rowTag: .volume) {
            
        }
    }
}
