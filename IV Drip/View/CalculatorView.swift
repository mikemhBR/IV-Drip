//
//  CalculatorView.swift
//  IV Drip
//
//  Created by Michael Mattesco Horta on 13/08/23.
//

import SwiftUI



struct CalculatorView: View {
    
    @EnvironmentObject var navigationModel: NavigationModel
    
    @AppStorage(Constants.AppStorage.patientWeight) var storedPatientWeight = 0.0
    
    @State private var selectedTab = 0
    
    @State private var patientWeight = 0.0
    
    @State private var drugInBag = 0.0
    @State var showDrugWeightWheelPicker = false
    @State private var selectedWeightFactor = WeightOptions.miligrams
    
    @State private var volumeInt = 0.0
    @State var showVolumeWheelPicker = false
    
    @State private var desiredRateField = 0.0
    @State var showConcentrationWheelPicker = false
    @State private var selectedConcentrationFactor = DoseOptions.concentrationDose(.mcgKgMin)
    
    @State private var currentInfusionRate = 0.0
    @State var showInfusionRateWheelPicker = false
    @State private var selectedInfusionFactor = InfusionRateOptions.mlHour
    
    @State private var infusionRateResult  = 0.0
    @State private var infusionResultString = "-"
    @State private var concentrationResult = 0.0
    
    @State var currentlySelectedRow: RowType? = RowType.weight
    
    var body: some View {
        ScrollView {
            VStack (spacing: Constants.Layout.kPadding) {
                
                SectionHeaderView(sectionTitle: "Quick Calculator") {
                    withAnimation {
                        navigationModel.navigateTo(to: .homeView)
                    }
                }
                
                Spacer()
                    .frame(height: 1)
                
                Text("Patient Weight")
                    .subHeadlineTitle()
                
                HorizontalWheelPicker(viewPadding: Constants.Layout.kPadding/2, initialWeight: Int(storedPatientWeight), patientWeight: $patientWeight)
                
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
                        
                        compositionView
                            .padding(.vertical, Constants.Layout.kPadding)
                        
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
                        
                        infusionResultView
                        
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
                        
                        
                        compositionView
                            .padding(.vertical, Constants.Layout.kPadding)
                        
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
            .onAppear {
                DispatchQueue.main.async {
                    let initialWeight = Int(storedPatientWeight.rounded(.down))
                    patientWeight = Double(initialWeight)
                }
            }
            .onChange(of: drugInBag) { newValue in
                calculateConcentration()
                getInfusionRateString()
            }
            .onChange(of: volumeInt) { newValue in
                calculateConcentration()
                getInfusionRateString()
            }
            .onChange(of: desiredRateField) { newValue in
                getInfusionRateString()
            }
            .onChange(of: currentInfusionRate) { newValue in
                calculateConcentration()
            }
            .onChange(of: patientWeight, perform: { newValue in
                getInfusionRateString()
            })
            .onChange(of: selectedConcentrationFactor, perform: { newValue in
                getInfusionRateString()
            })
            .onDisappear() {
                storedPatientWeight = patientWeight
            }
            .padding(Constants.Layout.kPadding/2)
        }
    }
    
    var compositionView: some View {
        let drugString = NumberModel(value: drugInBag, numberType: .mass).description
        let volumeString = NumberModel(value: volumeInt, numberType: .volume).description
        
        return VStack (alignment: .leading, spacing: Constants.Layout.kPadding/4) {
            HStack (spacing: Constants.Layout.kPadding/2) {
                Text("Drug in Bag")
                    .fixedSize()
                    .font(.system(size: 12, weight: .light))
                    .foregroundColor(Color("Text"))
                
                
                Rectangle()
                    .frame(maxWidth: .infinity)
                    .frame(height: 1)
                    .foregroundColor(Color("Text").opacity(0.2))
                
                Text("\(drugString) \(selectedWeightFactor.rawValue)")
                    .font(.system(size: 12, weight: .light))
                    .foregroundColor(Color("Text"))
            }
            
            HStack (spacing: Constants.Layout.kPadding/2) {
                Text("Fluid")
                    .font(.system(size: 12, weight: .light))
                    .foregroundColor(Color("Text"))
                
                Rectangle()
                    .frame(maxWidth: .infinity)
                    .frame(height: 1)
                    .foregroundColor(Color("Text").opacity(0.2))
                
                Text("\(volumeString) ml")
                    .font(.system(size: 12, weight: .light))
                    .foregroundColor(Color("Text"))
            }
            
            Text("Solution: \(drugString)mg / \(volumeString)ml")
                .frame(maxWidth: .infinity, alignment: .trailing)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color("Text"))
            
            Text("Concentration: \(getConcentrationString()) mg / ml")
                .frame(maxWidth: .infinity, alignment: .trailing)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color("Text"))
        }
        .padding(8)
        .background(Color.theme.rowBackground)
        .cornerRadius(Constants.Layout.cornerRadius.small.rawValue)
        
    }
    
    
    var infusionResultView: some View {
        VStack {
            VStack {
                Text("Infusion Rate")
                    .font(.system(size: 24, weight: .light))
                    .foregroundColor(Color("Text"))
                
                Text(infusionResultString)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color("Text"))
                
            }
            .padding(Constants.Layout.kPadding)
            .background(Color.white)
            .cornerRadius(Constants.Layout.cornerRadius.medium.rawValue)
            
            
//            Picker("Select Infusion Factor", selection: $desiredInfusionRateFactor) {
//                Text("ml/h").tag(0)
//                Text("ml/min").tag(1)
//            }
//            .pickerStyle(.segmented)
//            .frame(width: 240)
//            .frame(maxWidth: .infinity, alignment: .center)
            
        }
    }
    
    func getInfusionRateString() {
        if drugInBag > 0.0 && volumeInt > 0.0 {
            let result = InfusionCalculator.getInfusionRate(desiredInfusionRate: desiredRateField, inputRateMethod: selectedConcentrationFactor, solutionConcentrationMgMl: concentrationResult, patientWeight: patientWeight, outputRateMethod: .mlHour)
            
            print(result)
            infusionResultString = NumberModel(value: result, numberType: .infusionRate).description
            
        } else {
            infusionResultString = "-"
        }
        
        
    }
    
    func getConcentrationString() -> String {
        if drugInBag > 0.0 && volumeInt > 0.0 {
            return NumberModel(value: drugInBag/volumeInt, numberType: .concentration).description
        } else {
            return "-"
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
        
    func calculateConcentration() {
        if drugInBag != 0 && volumeInt != 0 {
            concentrationResult = drugInBag/volumeInt
        }
    }
}

struct CalculatorView_Previews: PreviewProvider {
    static var previews: some View {
        CalculatorView()
    }
}
