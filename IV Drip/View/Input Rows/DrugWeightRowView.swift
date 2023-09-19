//
//  DrugWeightRowView.swift
//  IV Drip
//
//  Created by Michael Mattesco Horta on 13/08/23.
//

import SwiftUI

struct DrugWeightRowView: View {
    
    let itemTitle: String
    let pickerIntCases: Int
    let pickerDecimalCases: Int
    
    @Binding var showPickerWheel: Bool
    @State var inputTextField = "0.0"
    @State var inputDouble: Double
    
    @Binding var outputValue: Double
    @Binding var selectedWeightOption: WeightOptions
    
    @State private var weightOptions: WeightOptions = .miligrams
    
    @Binding var currentlySelectedRow: RowType?
    
    var rowTag: RowType = .drugInBag
    
    let buttonTapped: ()->()
    
    init(itemTitle: String, pickerIntCases: Int, pickerDecimalCases: Int, showPickerWheel: Binding<Bool>, inputDouble: Double = 0.0, userValue: Binding<Double>, selectedWeightOption: Binding<WeightOptions>, weightOptions: WeightOptions = .miligrams, currentlySelectedRow: Binding<RowType?>, rowTag: RowType, buttonTapped: @escaping () -> Void) {
        self.itemTitle = itemTitle
        self.pickerIntCases = pickerIntCases
        self.pickerDecimalCases = pickerDecimalCases
        self._showPickerWheel = showPickerWheel
        self._inputTextField = State(initialValue: String(format: "%.1f", inputDouble))
        self._inputDouble = State(initialValue: inputDouble)
        self._outputValue = userValue
        self._selectedWeightOption = selectedWeightOption
        self.weightOptions = weightOptions
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
                
                TextField("Drug Weight", text: $inputTextField, onEditingChanged: { isEditing in
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
                    .textSelection(.disabled)
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
                    Picker("test", selection: $weightOptions) {
                        ForEach(WeightOptions.allCases, id: \.self) { option in
                            Text(option.rawValue)
                                .font(.system(size: 14))
                                
                        }
                    }
                } label: {
                    Text(weightOptions.rawValue)
                        .modifier(InputRowButtonModifier())
                }
                
            }
            
            if showPickerWheel && currentlySelectedRow == rowTag {
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
        .padding(Constants.Layout.kPadding/2)
        .background(Color("Row Background"))
        .cornerRadius(Constants.Layout.kPadding/2)
        .onChange(of: inputDouble) { newValue in
            inputTextField = String(format: "%.\(pickerDecimalCases)f", newValue)
            outputValue = newValue
        }
        .onChange(of: weightOptions) { newValue in
            selectedWeightOption = newValue
        }
        
    }
}

struct DrugWeightRowView_Previews: PreviewProvider {
    static var previews: some View {
        DrugWeightRowView(itemTitle: "Test", pickerIntCases: 3, pickerDecimalCases: 1, showPickerWheel: .constant(false), userValue: .constant(0), selectedWeightOption: .constant(.miligrams), currentlySelectedRow: .constant(.drugInBag), rowTag: .drugInBag) {
            
        }
    }
}
