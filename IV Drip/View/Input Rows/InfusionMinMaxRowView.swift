//
//  InfusionMinMaxRowView.swift
//  IV Drip
//
//  Created by Michael Mattesco Horta on 30/08/23.
//

import SwiftUI

struct InfusionMinMaxRowView: View {
    @State private var minTextField = "0.0"
    @State private var maxTextField = "0.0"
    let initialMin: Double
    let initialMax: Double
    
    @Binding var outputMin: Double
    @Binding var outputMax: Double
    
    @Binding var selectedInfusionDoseOption: ConcentrationOptions
    
    @Binding var currentlySelectedRow: RowType?
    
    let buttonTapped: ()->()
    
    
    @State private var showMinPickerWheel = false
    @State private var showMaximumPickerWheel = false
    
    init(initialMin: Double = 0.0, initialMax: Double = 0.0, outputMin: Binding<Double>, outputMax: Binding<Double>, selectedInfusionDoseOption: Binding<ConcentrationOptions>, currentlySelectedRow: Binding<RowType?>, buttonTapped: @escaping () -> Void) {
        self.initialMin = initialMin
        self.initialMax = initialMax
        self._outputMin = outputMin
        self._outputMax = outputMax
        self._selectedInfusionDoseOption = selectedInfusionDoseOption
        self._currentlySelectedRow = currentlySelectedRow
        self.buttonTapped = buttonTapped
        
    }
    
    var body: some View {
        VStack (spacing: Constants.Layout.kPadding/4) {
            VStack {
                HStack (spacing: Constants.Layout.kPadding/2) {
                    Text("MIN Dose")
                        .font(.system(size: Constants.Layout.fontSize.inputRow.rawValue, weight: .bold))
                        .foregroundColor(Color("Text"))
                         
                    Spacer()
                    
                    Button {
                        withAnimation {
                            currentlySelectedRow = .minimumDose
                            showMinPickerWheel.toggle()
                        }
                    } label: {
                        Image(systemName: "plusminus.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 28)
                    }
                    
                    TextField("Infusion Velocity", text: $minTextField, onEditingChanged: { isEditing in
                        if isEditing {
                            if Double(minTextField) == 0.0 {
                                DispatchQueue.main.async {
                                    minTextField = ""
                                }
                            }
                        } else {
                            outputMin = Double(minTextField) ?? 0.0
                        }
                    })
                        .modifier(InputRowTextFieldModifier())
                        .disabled(showMinPickerWheel)
                        .onTapGesture {
                            withAnimation{
                                showMinPickerWheel = false
                                showMaximumPickerWheel = false
                            }
                        }
                        .onSubmit {
                            outputMin = Double(minTextField) ?? 0.0
                        }
                     
                    Menu {
                        Picker("test", selection: $selectedInfusionDoseOption) {
                            ForEach(ConcentrationOptions.allCases, id: \.self) { option in
                                Text(option.rawValue)
                                    .font(.system(size: 14))
                                    
                            }
                        }
                    } label: {
                        Text(selectedInfusionDoseOption.rawValue)
                            .modifier(InputRowButtonModifier())
                    }
                    

                    
                    
                    
                }
                
                if showMinPickerWheel && (currentlySelectedRow == .minimumDose) {
                    DecimalWheelPicker(intCases: 3, decimalCases: 2, selection: $outputMin, initialValue: outputMin)
                        
                        
                    Button("OK") {
                        minTextField = String(format: "%.2f", outputMin)
                        currentlySelectedRow = .maximumDose
                        withAnimation {
                            showMinPickerWheel = false
                            showMaximumPickerWheel = true
                        }
                    }
                }
                    
                
            }
            .padding(8)
            .background(Color("Row Background"))
            .cornerRadius(8)
            .onChange(of: outputMin) { newValue in
                minTextField = String(format: "%.2f", newValue)
            }
            
            
            
            
            //MARK: Max Dose
            VStack {
                HStack (spacing: Constants.Layout.kPadding/2) {
                    Text("MAX Dose")
                        .font(.system(size: Constants.Layout.fontSize.inputRow.rawValue, weight: .bold))
                        .foregroundColor(Color("Text"))
                         
                    Spacer()
                    
                    Button {
                        withAnimation {
                            currentlySelectedRow = .maximumDose
                            showMaximumPickerWheel.toggle()
                        }
                    } label: {
                        Image(systemName: "plusminus.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 28)
                    }
                    
                    TextField("Infusion Velocity", text: $maxTextField, onEditingChanged: { isEditing in
                        if isEditing {
                            if Double(maxTextField) == 0.0 {
                                DispatchQueue.main.async {
                                    maxTextField = ""
                                }
                            }
                        } else {
                            outputMax = Double(maxTextField) ?? 0.0
                        }
                    })
                        .modifier(InputRowTextFieldModifier())
                        .disabled(showMaximumPickerWheel)
                        .onTapGesture {
                            withAnimation{
                                showMinPickerWheel = false
                                showMaximumPickerWheel = false
                            }
                        }
                        .onSubmit {
                            outputMax = Double(maxTextField) ?? 0.0
                        }
                     
                    Menu {
                        Picker("test", selection: $selectedInfusionDoseOption) {
                            ForEach(ConcentrationOptions.allCases, id: \.self) { option in
                                Text(option.rawValue)
                                    .font(.system(size: 14))
                                    
                            }
                        }
                    } label: {
                        Text(selectedInfusionDoseOption.rawValue)
                            .modifier(InputRowButtonModifier())
                    }
                    

                    
                    
                    
                }
                
                if showMaximumPickerWheel && (currentlySelectedRow == .maximumDose) {
                    DecimalWheelPicker(intCases: 3, decimalCases: 2, selection: $outputMax, initialValue: outputMax)
                        
                        
                    Button("OK") {
                        maxTextField = String(format: "%.2f", outputMax)
                        withAnimation {
                            showMaximumPickerWheel = false
                        }
                        buttonTapped()
                    }
                }
                    
                
            }
            .padding(8)
            .background(Color("Row Background"))
            .cornerRadius(8)
            .onChange(of: outputMax) { newValue in
                maxTextField = String(format: "%.2f", newValue)
            }
        }
        
        .onAppear() {
            if initialMin != 0.0 {
                outputMin = initialMin
            }
            
            if initialMax != 0.0 {
                outputMax = initialMax
            }
        }
        
    }
}

