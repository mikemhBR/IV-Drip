//
//  MySolutionCalculator.swift
//  IV Drip
//
//  Created by Michael Mattesco Horta on 25/08/23.
//

import SwiftUI

struct MySolutionCalculatorView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @AppStorage(Constants.AppStorage.patientWeight) var storedPatientWeight = 0
    
    @EnvironmentObject var navigationModel: NavigationModel
    
    let selectedSolution: SolutionListClass
    
    @State private var patientWeight: Double = 0.0
    
    @State private var selectedTab = 0
    
    @State private var selectedConcentrationFactor: ConcentrationOptions = .mcgKgMin
    @State private var desiredRateField = 0.0
    @State private var currentlySelectedRow: RowType?
    @State private var showConcentrationWheelPicker = false
    
    @State private var showPushDoseWheelPicker = false
    @State private var pushDoseRateField = 0.0
    @State private var selectedPushDoseFactor: PushDoseOptions = .mgKg
    
    @State private var desiredInfusionRateFactor = 0
    
    @State private var infusionRateResultString = "-"
    @State private var pushDoseResultString = "-"
    
    @State private var inverseInfusionCalculator = false
    @State private var currentInfusionRate = 0.0
    @State private var infusionRateFactor: InfusionRateOptions = .mlHour
    @State private var desiredInversionInfusionFactor: ConcentrationOptions = .mcgKgMin
    @State private var inverseInfusionRateString = "-"
    
    
    var body: some View {
        VStack (alignment: .leading, spacing: Constants.Layout.kPadding) {
            SectionHeaderView(sectionTitle: "Custom Solution Calculator") {
                withAnimation {
                    dismiss()
                }
            }
            
            
            ScrollView {
                
                VStack (spacing: Constants.Layout.kPadding) {
                    SolutionListTileView(solution: selectedSolution)
                    
                    
                    Text("Patient Weight")
                        .sectionHeaderStyle()
                    
                    HorizontalWheelPicker(viewPadding: Constants.Layout.kPadding/2, initialWeight: storedPatientWeight, patientWeight: $patientWeight)
                    
                    
                    Spacer()
                        .frame(height: 1)
                    
                    Picker("Select Calculator Type", selection: $selectedTab) {
                        Text("Infusion Rate").tag(0)
                        Text("Dose").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 240)
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                    if selectedTab == 0 {
                        HStack (spacing: 8) {
                            Image(systemName: "arrow.up.arrow.down.square")
                                .onTapGesture {
                                    withAnimation {
                                        inverseInfusionCalculator.toggle()
                                    }
                                }
                            
                            if !inverseInfusionCalculator {
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
                            } else {
                                InfusionRowView(
                                    itemTitle: "Current Infusion",
                                    pickerIntCases: 3,
                                    pickerDecimalCases: 1,
                                    userValue: $currentInfusionRate,
                                    selectedInfusionOption: $infusionRateFactor,
                                    currentlySelectedRow: $currentlySelectedRow) {
                                        
                                    }
                            }
                            
                        }
                        
                    } else {
                        
                        
                        PushDoseRowView(itemTitle: "Push Dose",
                                        pickerIntCases: 3,
                                        pickerDecimalCases: 1,
                                        showPickerWheel: $showPushDoseWheelPicker,
                                        userValue: $pushDoseRateField,
                                        selectedPushDoseOption: $selectedPushDoseFactor,
                                        currentlySelectedRow: $currentlySelectedRow,
                                        rowTag: .desiredRate) {
                            withAnimation {
                                currentlySelectedRow = nil
                                showPushDoseWheelPicker = false
                            }
                        }
                                        .onTapGesture {
                                            withAnimation {
                                                currentlySelectedRow = .desiredRate
                                            }
                                        }
                        
                        
                        
                    }
                    
                    Divider()
                    
                    if selectedTab == 0 {
                        if !inverseInfusionCalculator {
                            infusionResultView
                        } else {
                            inverseInfusionResultView
                        }
                        
                    } else {
                        pushDoseResultView
                    }
                    
                    infusionRangeView
                }
                
                
                
            }
            
            
        }
        .padding(Constants.Layout.kPadding/2)
        .background(Color("Background 200"))
        .onChange(of: desiredRateField) { newValue in
            getInfusionRate()
        }
        .onChange(of: patientWeight) { newValue in
            getInfusionRate()
            getPushDose()
            getInverseInfusionRate()
        }
        .onChange(of: desiredInfusionRateFactor) { newValue in
            getInfusionRate()
        }
        .onChange(of: selectedConcentrationFactor) { newValue in
            getInfusionRate()
        }
        .onChange(of: pushDoseRateField) { newValue in
            getPushDose()
        }
        .onChange(of: selectedPushDoseFactor) { newValue in
            getPushDose()
        }
        .onChange(of: infusionRateFactor, perform: { newValue in
            getInverseInfusionRate()
        })
        .onChange(of: desiredInversionInfusionFactor, perform: { newValue in
            getInverseInfusionRate()
        })
        .onChange(of: currentInfusionRate, perform: { newValue in
            getInverseInfusionRate()
        })
        .onAppear() {
            patientWeight = Double(storedPatientWeight)
        }
        .onDisappear {
            storedPatientWeight = Int(patientWeight.rounded(.down))
        }
        
    }
    
    var infusionResultView: some View {
        VStack {
            VStack {
                Text("Infusion Rate")
                    .font(.system(size: 24, weight: .light))
                    .foregroundColor(Color("Text"))
                
                Text(infusionRateResultString)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color("Text"))
                
            }
            .padding(Constants.Layout.kPadding)
            .background(Color.white)
            .cornerRadius(Constants.Layout.cornerRadius.medium.rawValue)
            
            
            Picker("Select Infusion Factor", selection: $desiredInfusionRateFactor) {
                Text("ml/h").tag(0)
                Text("ml/min").tag(1)
            }
            .pickerStyle(.segmented)
            .frame(width: 240)
            .frame(maxWidth: .infinity, alignment: .center)
            
        }
    }
    
    var inverseInfusionResultView: some View {
        VStack {
            VStack {
                Text("Infusion Rate")
                    .font(.system(size: 24, weight: .light))
                    .foregroundColor(Color("Text"))
                
                Text(inverseInfusionRateString)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color("Text"))
                
            }
            .padding(Constants.Layout.kPadding)
            .background(Color.white)
            .cornerRadius(Constants.Layout.cornerRadius.medium.rawValue)
            
            
            Menu {
                Picker("Method", selection: $desiredInversionInfusionFactor) {
                    ForEach(ConcentrationOptions.allCases, id: \.self) { option in
                        Text(option.rawValue)
                            .font(.system(size: 14))
                            
                    }
                }
            } label: {
                Text(desiredInversionInfusionFactor.rawValue)
                    .modifier(InputRowButtonModifier(buttonWidth: 120))
                    .frame(width: 120)
            }
            
            
        }
    }
    
    func getInverseInfusionRate() {
        let solutionConcentration = solutionConcentration()
        
        let result = InfusionCalculator.getRateFromInfusion(
            currentInfusionRate: currentInfusionRate,
            infusionRateFactor: infusionRateFactor,
            solutionConcentrationMgMl: solutionConcentration,
            patientWeight: patientWeight,
            outputRateFactor: desiredInversionInfusionFactor)
        
        DispatchQueue.main.async {
            inverseInfusionRateString = String(format: "%.2f", result) + " " + desiredInversionInfusionFactor.rawValue
        }
    }
    
    var pushDoseResultView: some View {
        VStack {
            VStack {
                Text("Push Dose (ml)")
                    .font(.system(size: 24, weight: .light))
                    .foregroundColor(Color("Text"))
                
                Text(pushDoseResultString)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color("Text"))
                
            }
            .padding(Constants.Layout.kPadding)
            .background(Color.white)
            .cornerRadius(Constants.Layout.cornerRadius.medium.rawValue)
            
            
        }
    }
    
    @ViewBuilder
    var infusionRangeView: some View {
        if let safeMin = selectedSolution.solutionEntity?.solution_min, let safeMax = selectedSolution.solutionEntity?.solution_max  {
            
            if safeMin == 0.0 || safeMax == 0.0 {
                Color.clear
            } else {
                let outputRateFactor: InfusionRateOptions = desiredInfusionRateFactor == 0 ? .mlHour : .mlMin
                
                let minRate = InfusionCalculator.getInfusionRate(desiredInfusionRate: safeMin, desiredRateMethod: .mcgKgMin, solutionConcentrationMgMl: solutionConcentration(), patientWeight: patientWeight, outputRateMethod: outputRateFactor)
                
                let maxRate = InfusionCalculator.getInfusionRate(desiredInfusionRate: safeMax, desiredRateMethod: .mcgKgMin, solutionConcentrationMgMl: solutionConcentration(), patientWeight: patientWeight, outputRateMethod: outputRateFactor)
                
                VStack (alignment: .leading) {
                    Text("Infusion Range")
                        .sectionHeaderStyle()
                    
                    HStack {
                        VStack (alignment: .leading) {
                            Text("Mininum")
                            
                            Text(String(format: "%.2f", safeMin))
                            
                            Text(String(format: "%.1f", minRate) + " " + outputRateFactor.rawValue)
                        }
                        
                        Spacer()
                        
                        VStack (alignment: .leading){
                            Text("Maximum")
                            
                            Text(String(format: "%.2f", safeMax))
                            
                            Text(String(format: "%.1f", maxRate) + " " + outputRateFactor.rawValue)
                        }
                    }
                }
            }
            
            
        } else {
            Color.clear
        }
        
        
    }
    
    func solutionConcentration() -> Double {
        guard let safeSolutionEntity = selectedSolution.solutionEntity else { return 999 }
        let solutionWeight = safeSolutionEntity.drug_weight_amp*safeSolutionEntity.amp_number
        let solutionVolume = (safeSolutionEntity.drug_volume_amp*safeSolutionEntity.amp_number) + safeSolutionEntity.dilution_volume
        
        return solutionWeight/solutionVolume
        
    }
    
    func getInfusionRate() {
        let outputRateFactor: InfusionRateOptions = desiredInfusionRateFactor == 0 ? .mlHour : .mlMin
        
        let solutionConcentration = solutionConcentration()
        
        let infusionRate = InfusionCalculator.getInfusionRate(desiredInfusionRate: desiredRateField, desiredRateMethod: selectedConcentrationFactor, solutionConcentrationMgMl: solutionConcentration, patientWeight: patientWeight, outputRateMethod: outputRateFactor)
        
        DispatchQueue.main.async {
            infusionRateResultString = String(format: "%.1f", infusionRate) + " " + outputRateFactor.rawValue
        }
    }
    
    func getPushDose() {
        let solutionConcentration = solutionConcentration()
        
        let pushDose = InfusionCalculator.getPushDose(desiredPushDose: pushDoseRateField, desiredPushMethod: selectedPushDoseFactor, solutionConcentrationMgMl: solutionConcentration, patientWeight: patientWeight)
        
        DispatchQueue.main.async {
            pushDoseResultString = String(format: "%.1f", pushDose) + " ml"
        }
    }
}

//struct MySolutionCalculator_Previews: PreviewProvider {
//    static var previews: some View {
//        MySolutionCalculatorView()
//            .environmentObject(NavigationModel.shared)
//            .environmentObject(DBBrain.shared)
//    }
//}


