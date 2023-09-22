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
    
    
    @State private var selectedConcentrationFactor: DoseOptions = .concentrationDose(.mcgKgMin)
    @State private var desiredRateField = 0.0
    @State private var currentlySelectedRow: RowType?
    @State private var showConcentrationWheelPicker = false
    
    @State private var showPushDoseWheelPicker = false
    @State private var pushDoseRateField = 0.0
    @State private var selectedPushDoseFactor: DoseOptions = .pushDose(.mgKg)
    
    @State private var desiredInfusionRateFactor = 0
    
    @State private var infusionRateResultString = "-"
    @State private var pushDoseResultString = "-"
    
    @State private var inverseInfusionCalculator = false
    @State private var currentInfusionRate = 0.0
    @State private var infusionRateFactor: InfusionRateOptions = .mlHour
    @State private var desiredInversionInfusionFactor: ConcentrationOptions = .mcgKgMin
    @State private var inverseInfusionRateString = "-"
    
    
    @State private var minDose: String?
    @State private var minInfusion: String?
    @State private var maxDose: String?
    @State private var maxInfusion: String?
    @State private var databaseDoseOption: DoseOptions?
    @State private var solutionConcentration = 0.0
    
    var body: some View {
        VStack (alignment: .leading, spacing: Constants.Layout.kPadding) {
            SectionHeaderView(sectionTitle: "Custom Solution Calculator") {
                withAnimation {
                    dismiss()
                }
            }
            
            
            ScrollView {
                
                VStack (spacing: Constants.Layout.kPadding) {
                    CustomSolutionHeaderView(solution: selectedSolution)
                    
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
                                .font(.system(size: 24))
                                .foregroundColor(Color.theme.blue)
                                .onTapGesture {
                                    withAnimation {
                                        inverseInfusionCalculator.toggle()
                                    }
                                }
                            
                            if !inverseInfusionCalculator {
                                ContinuousInfusionRowView(itemTitle: "Desired Rate",
                                                          isPushDose: false,
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
                        
                        ContinuousInfusionRowView(itemTitle: "Push Dose",
                                                  isPushDose: true,
                                                  pickerIntCases: 3,
                                                  pickerDecimalCases: 1,
                                                  showPickerWheel: $showPushDoseWheelPicker,
                                                  userValue: $pushDoseRateField,
                                                  selectedConcentrationOption: $selectedPushDoseFactor,
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
                        
                        //                        PushDoseRowView(itemTitle: "Push Dose",
                        //                                        pickerIntCases: 3,
                        //                                        pickerDecimalCases: 1,
                        //                                        showPickerWheel: $showPushDoseWheelPicker,
                        //                                        userValue: $pushDoseRateField,
                        //                                        selectedPushDoseOption: $selectedPushDoseFactor,
                        //                                        currentlySelectedRow: $currentlySelectedRow,
                        //                                        rowTag: .desiredRate) {
                        //                            withAnimation {
                        //                                currentlySelectedRow = nil
                        //                                showPushDoseWheelPicker = false
                        //                            }
                        //                        }
                        //                                        .onTapGesture {
                        //                                            withAnimation {
                        //                                                currentlySelectedRow = .desiredRate
                        //                                            }
                        //                                        }
                        
                        
                        
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
            getMinMax()
        }
        .onChange(of: desiredInfusionRateFactor) { newValue in
            infusionRateFactor = desiredInfusionRateFactor == 0 ? .mlHour : .mlMin
            getInfusionRate()
            getMinMax()
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
            getMinMax()
        })
        .onChange(of: currentInfusionRate, perform: { newValue in
            getInverseInfusionRate()
        })
        .onAppear() {
            patientWeight = Double(storedPatientWeight)
            setInitialDoseOption()
            getMinMax()
            
            if let safeConcentration = getSolutionConcentration() {
                solutionConcentration = safeConcentration
            }
            
            guard let safeSolution = selectedSolution.solutionEntity else { return }
            
            if safeSolution.solution_type == 0 {
                selectedTab = 1
            } else {
                selectedTab = 0
            }
            
        }
        
        .onDisappear {
            storedPatientWeight = Int(patientWeight.rounded(.down))
        }
    }
    
    func setInitialDoseOption() {
        guard let safeSolution = selectedSolution.solutionEntity else {return}
        
        if selectedSolution.solutionType == 1 {
            var initialFactor = DoseOptions.concentrationDose(.mcgKgMin)
            
            if safeSolution.min_max_factor != 0 {
                initialFactor = InfusionCalculator.getDatabaseRateFactor(databaseFactor: Int(safeSolution.min_max_factor))
            }
            
            selectedConcentrationFactor = initialFactor
            
        } else {
            var initialFactor = DoseOptions.pushDose(.mgKg)
            
            if safeSolution.min_max_factor != 0 {
                initialFactor = InfusionCalculator.getDatabaseRateFactor(databaseFactor: Int(safeSolution.min_max_factor))
            }
            selectedPushDoseFactor = initialFactor
        }
        
    }
    
    func getMinMax() {
        
        guard let safeSolution = selectedSolution.solutionEntity else {return}
        
        
        
        if selectedSolution.solutionType == 1 {
            
            
            if safeSolution.solution_min != 9999 {
                minDose = NumberModel(value: safeSolution.solution_min, numberType: .dose).description
                
                let testMinimumRate = DatabaseInfusionDoseStruct(initialValue: safeSolution.solution_min, databaseUnitOfMeasure: Int(safeSolution.min_max_factor))
                let minInfusionRate = InfusionCalculator.getInfusionRate(desiredInfusionRate: testMinimumRate.drugDose, inputRateMethod: testMinimumRate.unitOfMeasure, solutionConcentrationMgMl: solutionConcentration, patientWeight: patientWeight, outputRateMethod: infusionRateFactor)
                print(minInfusionRate)
                minInfusion = NumberModel(value: minInfusionRate, numberType: .infusionRate).description
                databaseDoseOption = testMinimumRate.unitOfMeasure
            }
            if safeSolution.solution_max != 9999 {
                maxDose = NumberModel(value: safeSolution.solution_max, numberType: .dose).description
                let testMaximumRate = DatabaseInfusionDoseStruct(initialValue: safeSolution.solution_max, databaseUnitOfMeasure: Int(safeSolution.min_max_factor))
                let maxInfusionRate = InfusionCalculator.getInfusionRate(desiredInfusionRate: testMaximumRate.drugDose, inputRateMethod: testMaximumRate.unitOfMeasure, solutionConcentrationMgMl: solutionConcentration, patientWeight: patientWeight, outputRateMethod: infusionRateFactor)
                maxInfusion = NumberModel(value: maxInfusionRate, numberType: .infusionRate).description
                databaseDoseOption = testMaximumRate.unitOfMeasure
            }
            
            
            //TODO: Check if else statement can be deleted
        } else {
            
            
            if safeSolution.solution_min != 9999 {
                minDose = NumberModel(value: safeSolution.solution_min, numberType: .dose).description
                
                let testMinimumRate = DatabaseDoseStruct(initialValue: safeSolution.solution_min, databaseUnitOfMeasure: Int(safeSolution.min_max_factor))
                let minInfusionRate = InfusionCalculator.getPushDose(desiredPushDose: testMinimumRate.drugDose, inputDoseOption: testMinimumRate.unitOfMeasure, solutionConcentrationMgMl: solutionConcentration, patientWeight: patientWeight)
                minInfusion = NumberModel(value: minInfusionRate, numberType: .infusionRate).description
                databaseDoseOption = testMinimumRate.unitOfMeasure
                
            }
            if safeSolution.solution_max != 9999 {
                maxDose = NumberModel(value: safeSolution.solution_max, numberType: .dose).description
                let testMaximumRate = DatabaseDoseStruct(initialValue: safeSolution.solution_max, databaseUnitOfMeasure: Int(safeSolution.min_max_factor))
                let maxInfusionRate = InfusionCalculator.getPushDose(desiredPushDose: testMaximumRate.drugDose, inputDoseOption: testMaximumRate.unitOfMeasure, solutionConcentrationMgMl: solutionConcentration, patientWeight: patientWeight)
                maxInfusion = NumberModel(value: maxInfusionRate, numberType: .infusionRate).description
                databaseDoseOption = testMaximumRate.unitOfMeasure
            }
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
        guard let solutionConcentration = getSolutionConcentration() else { return }
        
        let result = InfusionCalculator.getRateFromInfusion(
            currentInfusionRate: currentInfusionRate,
            infusionRateFactor: infusionRateFactor,
            solutionConcentrationMgMl: solutionConcentration,
            patientWeight: patientWeight,
            outputRateFactor: desiredInversionInfusionFactor)
        
        let resultString = NumberModel(value: result, numberType: .concentration).description
        
        DispatchQueue.main.async {
            inverseInfusionRateString = "\(resultString) \(desiredInversionInfusionFactor.rawValue)"
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
    
    func showInfusionRange() -> Bool {
        guard let safeSolution = selectedSolution.solutionEntity else {return false}
        
        if selectedTab == safeSolution.solution_type {
            return false
        }
        
        if databaseDoseOption != selectedConcentrationFactor && databaseDoseOption != selectedPushDoseFactor {
            return false
        }
        
        return true
    }
    
    @ViewBuilder
    var infusionRangeView: some View {
        if let safeSolution = selectedSolution.solutionEntity  {
            
            if safeSolution.solution_min == 9999 || safeSolution.solution_max == 9999 {
                
                Color.clear
                
            } else if !showInfusionRange() {
                
                Color.clear
                
            } else {
                let outputRateFactor: InfusionRateOptions = desiredInfusionRateFactor == 0 ? .mlHour : .mlMin
                
                VStack (alignment: .leading) {
                    Text("Infusion Range")
                        .sectionHeaderStyle()
                    
                    HStack {
                        if let safeMin = minDose, let safeMinInfusion = minInfusion, let safeDoseOption = databaseDoseOption {
                            VStack (alignment: .center) {
                                Text("Mininum")
                                    .caption3Title()
                                    .padding(2)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.white)
                                    .cornerRadius(2)
                                
                                Text("\(safeMin) \(safeDoseOption.rawValue)")
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundColor(Color.theme.primaryText)
                                
                                if selectedTab == 0 {
                                    Text("\(safeMinInfusion) \(outputRateFactor.rawValue)")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(Color.theme.primaryText)
                                } else {
                                    Text("\(safeMinInfusion) ml")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(Color.theme.primaryText)
                                }
                                
                            }
                        }
                        
                        
                        Image(systemName: "circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(Color.theme.secondaryText)
                        
                        Rectangle()
                            .frame(maxWidth: .infinity)
                            .frame(height: 1)
                            .foregroundColor(Color.theme.secondaryText)
                        
                        Image(systemName: "circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(Color.theme.secondaryText)
                        
                        if let safeMax = maxDose, let safeMaxInfusion = maxInfusion, let safeDoseOption = databaseDoseOption {
                            VStack (alignment: .center) {
                                Text("Maximum")
                                    .caption3Title()
                                    .padding(2)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.white)
                                    .cornerRadius(2)
                                
                                Text("\(safeMax) \(safeDoseOption.rawValue)")
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundColor(Color.theme.primaryText)
                                
                                if selectedTab == 0 {
                                    Text("\(safeMaxInfusion) \(outputRateFactor.rawValue)")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(Color.theme.primaryText)
                                } else {
                                    Text("\(safeMaxInfusion) ml")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(Color.theme.primaryText)
                                }
                                
                            }
                        }
                        
                    }
                }
            }
            
            
        } else {
            Color.clear
        }
        
        
    }
    
    func getSolutionConcentration() -> Double? {
        guard let safeSolutionEntity = selectedSolution.solutionEntity else { return nil }
        let solutionWeight = safeSolutionEntity.drug_weight_amp*safeSolutionEntity.amp_number
        let solutionVolume = (safeSolutionEntity.drug_volume_amp*safeSolutionEntity.amp_number) + safeSolutionEntity.dilution_volume
        
        return solutionWeight/solutionVolume
        
    }
    
    func getInfusionRate() {
        
        guard desiredRateField > 0.0 else { return }
        
        let testInfusion = DatabaseInfusionDoseStruct(initialValue: desiredRateField, unitOfMeasure: selectedConcentrationFactor)
        
        let infusionRate = InfusionCalculator.getInfusionRate(desiredInfusionRate: desiredRateField, inputRateMethod: testInfusion.unitOfMeasure, solutionConcentrationMgMl: solutionConcentration, patientWeight: patientWeight, outputRateMethod: infusionRateFactor)
        
        let rateString = NumberModel(value: infusionRate, numberType: .infusionRate).description
        
        DispatchQueue.main.async {
            infusionRateResultString = "\(rateString) \(infusionRateFactor.rawValue)"
        }
    }
    
    func getPushDose() {
        
        guard pushDoseRateField > 0.0 else { return }
        
        let testPush = DatabasePushDoseStruct(initialValue: desiredRateField, unitOfMeasure: selectedPushDoseFactor)
        let pushDose = InfusionCalculator.getPushDose(desiredPushDose: pushDoseRateField, inputDoseOption: testPush.unitOfMeasure, solutionConcentrationMgMl: solutionConcentration, patientWeight: patientWeight)
        
        let doseString = NumberModel(value: pushDose, numberType: .infusionRate).description
        DispatchQueue.main.async {
            pushDoseResultString = "\(doseString) ml"
        }
    }
}


struct CustomSolutionHeaderView: View {
    
    let solution: SolutionListClass
    
    let mainComponentWeightString: String
    let numberAmpsString: String
    let dilutionVolumeString: String
    let finalWeightString: String
    let finalVolumeString: String
    let solutionConcentration: String
    let unitOfMeasure: String
    
    init(solution: SolutionListClass) {
        self.solution = solution
        self.mainComponentWeightString = String(format: "%.1f", solution.mainComponentWeightPerAmp)
        self.numberAmpsString = String(format: "%.1f", solution.numberAmps)
        self.dilutionVolumeString = String(format: "%.1f", solution.dilutionVolume)
        self.finalWeightString = String(format: "%.1f", solution.mainComponentWeightPerAmp*solution.numberAmps)
        self.finalVolumeString = String(format: "%.1f", (solution.volumePerAmp*solution.numberAmps) + solution.dilutionVolume)
        self.unitOfMeasure = solution.solutionEntity?.drug_weight_unit == 0 ? "mg" : "units"
        
        
        
        if let safeSolutionEntity = solution.solutionEntity {
            let solutionWeight = safeSolutionEntity.drug_weight_amp*safeSolutionEntity.amp_number
            let solutionVolume = (safeSolutionEntity.drug_volume_amp*safeSolutionEntity.amp_number) + safeSolutionEntity.dilution_volume
            
            self.solutionConcentration = NumberModel(value: solutionWeight/solutionVolume, numberType: .concentration).description
        } else {
            self.solutionConcentration = ""
        }
        
        
    }
    
    var body: some View {
        
        VStack (alignment: .leading, spacing: Constants.Layout.kPadding/2) {
            HStack {
                Text(solution.solutionName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color("Text"))
                
                Spacer()
                
                Image(systemName: solution.solutionType == 0 ? "syringe.fill" : "ivfluid.bag.fill")
                    .font(.system(size: 16))
                    .foregroundColor(Color("Text"))
            }
            
            
            
            compositionView
            
            doseRangeView
            
        }
        .padding(Constants.Layout.kPadding/2)
        .background(Color("Row Background"))
        .cornerRadius(Constants.Layout.cornerRadius.small.rawValue)
        
    }
    
    var compositionView: some View {
        VStack (alignment: .leading, spacing: Constants.Layout.kPadding/4) {
            HStack (spacing: Constants.Layout.kPadding/2) {
                Text("\(solution.mainComponentName) (\(mainComponentWeightString)\(unitOfMeasure)/amp)")
                    .fixedSize()
                    .font(.system(size: 12, weight: .light))
                    .foregroundColor(Color("Text"))
                
                
                Rectangle()
                    .frame(maxWidth: .infinity)
                    .frame(height: 1)
                    .foregroundColor(Color("Text").opacity(0.2))
                
                Text("\(numberAmpsString) amps")
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
                
                Text("\(dilutionVolumeString) ml")
                    .font(.system(size: 12, weight: .light))
                    .foregroundColor(Color("Text"))
            }
            
            Text("Solution: \(finalWeightString)mg / \(finalVolumeString)ml")
                .frame(maxWidth: .infinity, alignment: .trailing)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color("Text"))
            
            Text("Concentration: \(solutionConcentration) mg / ml")
                .frame(maxWidth: .infinity, alignment: .trailing)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color("Text"))
        }
        
    }
    
    func getPushDoseFactor(factor: Int) -> PushDoseOptions {
        if factor == 0 {
            return .mg
        } else if factor == 1 {
            return .mgKg
        } else if factor == 5 {
            return .unitsKg
        } else {
            return .mg
        }
    }
    
    func getInfusionDoseFactor(factor: Int) -> ConcentrationOptions {
        if factor == 2 {
            return .mgMin
        } else if factor == 3 {
            return .mcgKgMin
        } else if factor == 4 {
            return .unitsMin
        } else {
            return .mgMin
        }
        
    }
    
    @ViewBuilder
    var doseRangeView: some View {
        
        
        if let safeSolution = solution.solutionEntity {
            let minDose = safeSolution.solution_min
            let maxDose = safeSolution.solution_max
            
            if safeSolution.solution_type == 1 {
                
                let testMinimum = DatabaseInfusionDoseStruct(initialValue: minDose, databaseUnitOfMeasure: Int(safeSolution.min_max_factor))
                
                let testMaximum = DatabaseInfusionDoseStruct(initialValue: maxDose, databaseUnitOfMeasure: Int(safeSolution.min_max_factor))
                
                if testMinimum.drugDose != 9999 || testMaximum.drugDose != 9999 {
                    
                    
                    VStack (alignment: .leading, spacing: 0) {
                        Text("Dose Range")
                            .captionTitle()
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        
                        HStack {
                            VStack (alignment: .leading, spacing: 2) {
                                Text("Mininum")
                                    .caption3Title()
                                    .padding(2)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.white)
                                    .cornerRadius(2)
                                
                                if testMinimum.drugDose != 9999 {
                                    Text("\(testMinimum.doseString) \(testMinimum.unitOfMeasure.rawValue)")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(Color.theme.primaryText)
                                }
                                
                                
                            }
                            .fixedSize(horizontal: true, vertical: false)
                            
                            Image(systemName: "circle.fill")
                                .font(.system(size: 12))
                                .foregroundColor(Color.theme.secondaryText)
                            
                            Rectangle()
                                .frame(maxWidth: .infinity)
                                .frame(height: 1)
                                .foregroundColor(Color.theme.secondaryText)
                            
                            Image(systemName: "circle.fill")
                                .font(.system(size: 12))
                                .foregroundColor(Color.theme.secondaryText)
                            
                            VStack (alignment: .leading, spacing: 2) {
                                Text("Maximum")
                                    .caption3Title()
                                    .padding(2)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.white)
                                    .cornerRadius(2)
                                
                                if testMaximum.drugDose != 9999 {
                                    Text("\(testMaximum.doseString) \(testMaximum.unitOfMeasure.rawValue)")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(Color.theme.primaryText)
                                }
                                
                            }
                            .fixedSize()
                        }
                        
                    }
                }
               
                
                
                
                
                
            } else {
                let testMinimum = DatabasePushDoseStruct(initialValue: minDose, databaseUnitOfMeasure: Int(safeSolution.min_max_factor))
                
                let testMaximum = DatabasePushDoseStruct(initialValue: maxDose, databaseUnitOfMeasure: Int(safeSolution.min_max_factor))
                
                VStack (alignment: .leading, spacing: 0) {
                    Text("Dose Range")
                        .captionTitle()
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    
                    HStack {
                        VStack (alignment: .leading, spacing: 2) {
                            Text("Mininum")
                                .caption3Title()
                                .padding(2)
                                .frame(maxWidth: .infinity)
                                .background(Color.white)
                                .cornerRadius(2)
                            
                            Text("\(testMinimum.doseString) \(testMinimum.unitOfMeasure.rawValue)")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Color.theme.primaryText)
                            
                        }
                        .fixedSize(horizontal: true, vertical: false)
                        
                        Image(systemName: "circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(Color.theme.secondaryText)
                        
                        Rectangle()
                            .frame(maxWidth: .infinity)
                            .frame(height: 1)
                            .foregroundColor(Color.theme.secondaryText)
                        
                        Image(systemName: "circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(Color.theme.secondaryText)
                        
                        VStack (alignment: .leading, spacing: 2) {
                            Text("Maximum")
                                .caption3Title()
                                .padding(2)
                                .frame(maxWidth: .infinity)
                                .background(Color.white)
                                .cornerRadius(2)
                            
                            Text("\(testMaximum.doseString) \(testMaximum.unitOfMeasure.rawValue)")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Color.theme.primaryText)
                        }
                        .fixedSize()
                    }
                    
                }
                
            }
            
        } else {
            Text("Test")
        }
    }
}

struct ContinuousInfusionRowView: View {
    
    let itemTitle: String
    let pickerIntCases: Int
    let pickerDecimalCases: Int
    let isPushDose: Bool
    
    @Binding var showPickerWheel: Bool
    @State var inputTextField = "0.0"
    @State var inputDouble = 0.0
    
    @Binding var userValue: Double
    @Binding var selectedConcentrationOption: DoseOptions
    
    
    let isFinalField = false
    
    @Binding var currentlySelectedRow: RowType?
    
    let rowTag: RowType
    let buttonTapped: ()->()
    
    init(itemTitle: String, isPushDose: Bool, pickerIntCases: Int, pickerDecimalCases: Int, showPickerWheel: Binding<Bool>, inputDouble: Double = 0.0, userValue: Binding<Double>, selectedConcentrationOption: Binding<DoseOptions>, currentlySelectedRow: Binding<RowType?>, rowTag: RowType, buttonTapped: @escaping () -> Void) {
        self.itemTitle = itemTitle
        self.isPushDose = isPushDose
        self.pickerIntCases = pickerIntCases
        self.pickerDecimalCases = pickerDecimalCases
        self._showPickerWheel = showPickerWheel
        _inputDouble = State(initialValue: inputDouble)
        _inputTextField = State(initialValue: String(format: "%.1f", inputDouble))
        self._userValue = userValue
        self._selectedConcentrationOption = selectedConcentrationOption
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
                    if !isPushDose {
                        Picker("test", selection: $selectedConcentrationOption) {
                            ForEach(DoseOptions.allInfusionOptions, id: \.self) { option in
                                Text(option.rawValue)
                                    .font(.system(size: 14))
                                
                            }
                        }
                    } else {
                        Picker("test", selection: $selectedConcentrationOption) {
                            ForEach(DoseOptions.allPushOptions, id: \.self) { option in
                                Text(option.rawValue)
                                    .font(.system(size: 14))
                                
                            }
                        }
                    }
                    
                } label: {
                    Text(selectedConcentrationOption.rawValue)
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
        .padding(Constants.Layout.kPadding/2)
        .background(Color("Row Background"))
        .cornerRadius(Constants.Layout.kPadding/2)
        .onChange(of: inputDouble) { newValue in
            inputTextField = String(format: "%.\(pickerDecimalCases)f", newValue)
            userValue = newValue
        }
        
    }
    
}
