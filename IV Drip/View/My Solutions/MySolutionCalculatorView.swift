//
//  MySolutionCalculator.swift
//  IV Drip
//
//  Created by Michael Mattesco Horta on 25/08/23.
//

import SwiftUI

struct MySolutionCalculatorView: View {
    
    @Environment(\.dismiss) var dismiss
    
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
                    
                    HorizontalWheelPicker(viewPadding: Constants.Layout.kPadding/2, patientWeight: $patientWeight)
                    
                    
                    Picker("Select Calculator Type", selection: $selectedTab) {
                        Text("Infusion Rate").tag(0)
                        Text("Dose").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 240)
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                    if selectedTab == 0 {
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
                        infusionResultView
                    } else {
                        pushDoseResultView
                    }
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
        .onAppear() {
            print(solutionConcentration())
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


