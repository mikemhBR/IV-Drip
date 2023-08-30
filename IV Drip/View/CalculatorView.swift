//
//  CalculatorView.swift
//  IV Drip
//
//  Created by Michael Mattesco Horta on 13/08/23.
//

import SwiftUI



struct CalculatorView: View {
    
    @State private var selectedTab = 0
    
    @State private var patientWeight = 0.0
    
    @State private var drugInBag = 0.0
    @State var showDrugWeightWheelPicker = false
    @State private var selectedWeightFactor = WeightOptions.miligrams
    
    @State private var volumeInt = 0.0
    @State var showVolumeWheelPicker = false
    
    @State private var desiredRateField = 0.0
    @State var showConcentrationWheelPicker = false
    @State private var selectedConcentrationFactor = ConcentrationOptions.mcgKgMin
    
    @State private var currentInfusionRate = 0.0
    @State var showInfusionRateWheelPicker = false
    @State private var selectedInfusionFactor = InfusionRateOptions.mlHour
    
    @State private var infusionRateResult  = 0.0
    @State private var concentrationResult = 0.0
    
    @State var currentlySelectedRow: RowType? = RowType.weight
    
    var body: some View {
        ScrollView {
            VStack (spacing: Constants.Layout.kPadding) {
                
                Spacer()
                    .frame(height: 1)
                
                Text("Patient Weight")
                    .subHeadlineTitle()
                
                HorizontalWheelPicker(viewPadding: Constants.Layout.kPadding/2, patientWeight: $patientWeight)
                
                Spacer()
                    .frame(height: 1)
                
                Picker("Select Calculator Type", selection: $selectedTab) {
                    Text("Infusion Rate").tag(0)
                    Text("Dose").tag(1)
                }
                .pickerStyle(.segmented)
                .frame(width: 240)

                
                
                if selectedTab == 0 {
                    VStack {
                        
                        
                        DrugWeightRowView(itemTitle: "Drug In Bag",
                                          pickerIntCases: 4,
                                          pickerDecimalCases: 1,
                                          showPickerWheel: $showDrugWeightWheelPicker,
                                          userValue: $drugInBag,
                                          selectedWeightOption: $selectedWeightFactor,
                                          currentlySelectedRow: $currentlySelectedRow,
                                          rowTag: .drugInBag
                        ) {
                            withAnimation {
                                currentlySelectedRow = .volume
                                showVolumeWheelPicker = true
                            }
                        }
                        .onTapGesture {
                            withAnimation {
                                currentlySelectedRow = .drugInBag
                            }
                        }
                        
                        VolumeRowView(showPickerWheel: $showVolumeWheelPicker, inputDouble: 0.0, outputValue: $volumeInt, currentlySelectedRow: $currentlySelectedRow, rowTag: .volume) {
                            withAnimation {
                                currentlySelectedRow = .desiredRate
                                showConcentrationWheelPicker = true
                            }
                        }
                        .onTapGesture {
                            withAnimation {
                                currentlySelectedRow = .volume
                            }
                        }
                        
                        ConcentrationRowView(itemTitle: "Desired Rate",
                                             pickerIntCases: 3,
                                             pickerDecimalCases: 1,
                                             showPickerWheel: $showConcentrationWheelPicker,
                                             userValue: $desiredRateField,
                                             selectedConcentrationOption: $selectedConcentrationFactor,
                                             currentlySelectedRow: $currentlySelectedRow,
                                             rowTag: .desiredRate
                        ) {
                            withAnimation {
                                currentlySelectedRow = nil
                                showConcentrationWheelPicker = false
                            }
                        }
                        .onTapGesture {
                            withAnimation {
                                currentlySelectedRow = .desiredRate
                            }
                        }
                        
                        Spacer()
                        
                        Text(String(format: "%.1f", infusionRateResult))
                            .font(.system(size: 44))
                        
                        Spacer()
                            .frame(height: Constants.Layout.kPadding)
                        

                    }
                    
                } else {
                    VStack {
                        
                        DrugWeightRowView(
                            itemTitle: "Drug In Bag",
                            pickerIntCases: 4,
                            pickerDecimalCases: 1,
                            showPickerWheel: $showDrugWeightWheelPicker,
                            userValue: $drugInBag,
                            selectedWeightOption: $selectedWeightFactor,
                            currentlySelectedRow: $currentlySelectedRow,
                            rowTag: .drugInBag
                        ) {
                            withAnimation {
                                currentlySelectedRow = .volume
                                showVolumeWheelPicker = true
                            }
                        }
                        .onTapGesture {
                            withAnimation {
                                currentlySelectedRow = .drugInBag
                            }
                        }
                    
                        
                        VolumeRowView(showPickerWheel: $showVolumeWheelPicker, inputDouble: 0.0, outputValue: $volumeInt, currentlySelectedRow: $currentlySelectedRow, rowTag: .volume) {
                            withAnimation {
                                currentlySelectedRow = .desiredRate
                                showInfusionRateWheelPicker = true
                            }
                        }
                        .onTapGesture {
                            withAnimation {
                                currentlySelectedRow = .volume
                            }
                        }
                        
                        InfusionRowView(itemTitle: "Current Infusion", pickerIntCases: 4, pickerDecimalCases: 1, userValue: $currentInfusionRate, selectedInfusionOption: $selectedInfusionFactor, currentlySelectedRow: $currentlySelectedRow) {
                            withAnimation {
                                currentlySelectedRow = nil
                                showInfusionRateWheelPicker = true
                            }
                        }
                        .onTapGesture {
                            withAnimation {
                                currentlySelectedRow = .infusionVelocity
                            }
                        }
                        
                        Spacer()
                        
                        if selectedTab == 0 {
                            Text(String(format: "%.1f", infusionRateResult))
                                .font(.system(size: 44))
                        } else {
                            concentrationResultView
                        }
                        
                        
                        
                    }
                }
                      
                
            }
            .onChange(of: drugInBag) { newValue in
                calculateConcentration()
                calculateInfusion()
            }
            .onChange(of: volumeInt) { newValue in
                calculateConcentration()
                calculateInfusion()
            }
            .onChange(of: desiredRateField) { newValue in
                calculateInfusion()
            }
            .onChange(of: currentInfusionRate) { newValue in
                calculateConcentration()
            }
        .padding(Constants.Layout.kPadding/2)
        }
    }
    
    var concentrationResultView: some View {
        VStack {
            HStack (alignment: .firstTextBaseline){
                Text(String(format: "%.1f", concentrationResult))
                    .font(.system(size: 44))
                    .alignmentGuide(VerticalAlignment.center) { _ in
                        15
                    }
                
                Text("mcg/kg/min")
            }
            
            HStack {
                HStack(alignment: .firstTextBaseline) {
                    Text("0.2")
                        .font(.system(size: 28))
                    Text("mcg/min")
                }
                
                HStack (alignment: .firstTextBaseline) {
                    Text("0.2")
                        .font(.system(size: 28))
                    Text("mcg/hour")
                }
            }
        }
    }
    
    func calculateInfusion() {
        var weightFactor = 1.0
        
        switch selectedWeightFactor {
        case .grams:
            weightFactor = pow(10, -3)
        case .miligrams:
            weightFactor = 1
        case .micrograms:
            weightFactor = pow(10, 3)
        case .units:
            weightFactor = 1
        }
        
        var timeFactor = 1.0
        var concentrationFactor = 1.0
        
        switch selectedConcentrationFactor {
        case .mcgKgMin:
            timeFactor = 60
            concentrationFactor = 1000
        case .mcgKgHour:
            timeFactor = 1
            concentrationFactor = 1000
        case .mcgMin:
            timeFactor = 1
            concentrationFactor = 1000
        case .mcgHour:
            timeFactor = 1
            concentrationFactor = 1000
        case .mgKgMin:
            timeFactor = 1
            concentrationFactor = 1000
        case .mgKgHour:
            timeFactor = 1
            concentrationFactor = 1000
        case .mgMin:
            timeFactor = 1
            concentrationFactor = 1000
        case .mgHour:
            timeFactor = 1
            concentrationFactor = 1000
        case .unitsMin:
            timeFactor = 60
            concentrationFactor = 1
        }
        
        if drugInBag != 0 && volumeInt != 0 && desiredRateField != 0 {
            infusionRateResult = (desiredRateField*Double(patientWeight)*timeFactor) / (drugInBag*weightFactor*concentrationFactor/Double(volumeInt))
        }
    }
    
    func calculateConcentration() {
        if drugInBag != 0 && volumeInt != 0 && currentInfusionRate != 0 {
            concentrationResult = ((drugInBag/Double(volumeInt))*currentInfusionRate*1000)/(Double(patientWeight)*60)
        }
    }
}

struct CalculatorView_Previews: PreviewProvider {
    static var previews: some View {
        CalculatorView()
    }
}
