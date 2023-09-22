//
//  ListDetailComponent.swift
//  IV Drip
//
//  Created by Michael Mattesco Horta on 29/08/23.
//

import SwiftUI

struct ListDetailComponent: View {
    
    let solution: SolutionListClass
    
    var patientWeight: Double
    
    @State private var mainComponentWeightString: String
    @State private var numberAmpsString: String
    @State private var dilutionVolumeString: String
    @State private var finalWeightString: String
    @State private var finalVolumeString: String
    @State private var minDose: String?
    @State private var minInfusion: String?
    @State private var maxDose: String?
    @State private var maxInfusion: String?
    @State private var doseOption: DoseOptions?
    @State private var solutionConcentration = 0.0
    
    var showHorizontalRange: Bool
    
    init(solution: SolutionListClass, patientWeight: Double) {
        self.solution = solution
        self.patientWeight = patientWeight
        
        self._mainComponentWeightString = State(initialValue: String(format: "%.1f", solution.mainComponentWeightPerAmp))
        self._numberAmpsString = State(initialValue: String(format: "%.1f", solution.numberAmps))
        self._dilutionVolumeString = State(initialValue: String(format: "%.1f", solution.dilutionVolume))
        self._finalWeightString = State(initialValue: String(format: "%.1f", solution.mainComponentWeightPerAmp*solution.numberAmps))
        self._finalVolumeString = State(initialValue: String(format: "%.1f", (solution.volumePerAmp*solution.numberAmps) + solution.dilutionVolume))
        
        if let safeSolution = solution.solutionEntity {
            if safeSolution.solution_min != 9999 && safeSolution.solution_max != 9999 {
                self.showHorizontalRange = true
            } else {
                self.showHorizontalRange = false
            }
        } else {
            self.showHorizontalRange = false
        }
        
        self._solutionConcentration = State(initialValue: getSolutionConcentration())
    }
    
    var body: some View {
        
        
        VStack (alignment: .leading, spacing: 4) {
            HStack {
                Text(solution.solutionName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color("Text"))
                
                Spacer()
                
                Image(systemName: solution.solutionType == 0 ? "syringe.fill" : "ivfluid.bag.fill")
                    .font(.system(size: 16))
                    .foregroundColor(Color("Text"))
            }
            
            
            HStack (spacing: Constants.Layout.kPadding/2) {
                Text("\(solution.mainComponentName) (\(mainComponentWeightString)mg/amp)")
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
            
            Text("Concentration: \(String(format: "%.2f", solutionConcentration))mg / ml")
                .frame(maxWidth: .infinity, alignment: .trailing)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color("Text"))
            
            Spacer()
                .frame(height: Constants.Layout.kPadding/2)
            
            doseRangeView
            
            Spacer()
                .frame(height: Constants.Layout.kPadding/2)
            
            horizontalRangeView
            
        }
        .padding(Constants.Layout.kPadding/2)
        .background(Color("Row Background"))
        .cornerRadius(Constants.Layout.cornerRadius.small.rawValue)
        .onAppear {
            getMinMax()
        }
        .onChange(of: patientWeight) { newValue in
            getMinMax()
        }
    }
    
    func getMinMax() {
        
        guard let safeSolution = solution.solutionEntity else {return}
        
        if solution.solutionType == 1 {
            if safeSolution.solution_min != 9999 {
                minDose = NumberModel(value: safeSolution.solution_min, numberType: .dose).description
                
                let testMinimumRate = DatabaseInfusionDoseStruct(initialValue: safeSolution.solution_min, databaseUnitOfMeasure: Int(safeSolution.min_max_factor))
                let minInfusionRate = InfusionCalculator.getInfusionRate(desiredInfusionRate: testMinimumRate.drugDose, inputRateMethod: testMinimumRate.unitOfMeasure, solutionConcentrationMgMl: solutionConcentration, patientWeight: patientWeight, outputRateMethod: .mlHour)
                minInfusion = NumberModel(value: minInfusionRate, numberType: .infusionRate).description
                doseOption = testMinimumRate.unitOfMeasure
            }
            if safeSolution.solution_max != 9999 {
                maxDose = NumberModel(value: safeSolution.solution_max, numberType: .dose).description
                let testMaximumRate = DatabaseInfusionDoseStruct(initialValue: safeSolution.solution_max, databaseUnitOfMeasure: Int(safeSolution.min_max_factor))
                let maxInfusionRate = InfusionCalculator.getInfusionRate(desiredInfusionRate: testMaximumRate.drugDose, inputRateMethod: testMaximumRate.unitOfMeasure, solutionConcentrationMgMl: solutionConcentration, patientWeight: patientWeight, outputRateMethod: .mlHour)
                maxInfusion = NumberModel(value: maxInfusionRate, numberType: .infusionRate).description
                doseOption = testMaximumRate.unitOfMeasure
            }
            
            
            //TODO: Check if else statement can be deleted
        } else {
            if safeSolution.solution_min != 9999 {
                minDose = NumberModel(value: safeSolution.solution_min, numberType: .dose).description
               
                let testMinimumRate = DatabaseInfusionDoseStruct(initialValue: safeSolution.solution_min, databaseUnitOfMeasure: Int(safeSolution.min_max_factor))
                let minInfusionRate = InfusionCalculator.getPushDose(desiredPushDose: testMinimumRate.drugDose, inputDoseOption: testMinimumRate.unitOfMeasure, solutionConcentrationMgMl: solutionConcentration, patientWeight: patientWeight)
                minInfusion = NumberModel(value: minInfusionRate, numberType: .infusionRate).description
                doseOption = testMinimumRate.unitOfMeasure
            }
            if safeSolution.solution_max != 9999 {
                maxDose = NumberModel(value: safeSolution.solution_min, numberType: .dose).description
                let testMaximumRate = DatabaseInfusionDoseStruct(initialValue: safeSolution.solution_max, databaseUnitOfMeasure: Int(safeSolution.min_max_factor))
                let maxInfusionRate = InfusionCalculator.getPushDose(desiredPushDose: testMaximumRate.drugDose, inputDoseOption: testMaximumRate.unitOfMeasure, solutionConcentrationMgMl: solutionConcentration, patientWeight: patientWeight)
                maxInfusion = NumberModel(value: maxInfusionRate, numberType: .infusionRate).description
                doseOption = testMaximumRate.unitOfMeasure
            }
        }
        
        
    }
    
    func getSolutionConcentration() -> Double {
        return (solution.mainComponentWeightPerAmp*solution.numberAmps)/(solution.volumePerAmp*solution.numberAmps + solution.dilutionVolume)
    }
    
    @ViewBuilder
    var doseRangeView: some View {
        if let safeSolution = solution.solutionEntity {
            if solution.solutionType == 1 && safeSolution.solution_min != 9999 {
                
                let testMinimum = DatabaseInfusionDoseStruct(initialValue: safeSolution.solution_min, databaseUnitOfMeasure: Int(safeSolution.min_max_factor))
                
                VStack (alignment: .leading, spacing: 0) {
                    Text("Dose Range")
                        .captionTitle()
                        .frame(maxWidth: .infinity, alignment: .center)
                        
                    
                    HStack {
                        VStack (alignment: .center, spacing: 2) {
                            Text("Mininum")
                                .caption3Title()
                                .padding(2)
                                .frame(maxWidth: .infinity)
                                .background(Color.white)
                                .cornerRadius(2)
                            
                            if let safeMinInfusion = minInfusion {
                                Text("\(testMinimum.doseString) \(testMinimum.unitOfMeasure.rawValue)")
                                    .font(.system(size: 13, weight: .light))
                                
                                Text("\(safeMinInfusion) ml/h")
                                    .font(.system(size: 14, weight: .bold))
                            }
                            
                        }
                        .fixedSize(horizontal: true, vertical: false)
                        
                        Image(systemName: "circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(Color.theme.secondaryText)
                        
                        Rectangle()
                            .frame(maxWidth: .infinity)
                            .frame(height: 1)
                        
                        Image(systemName: "circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(Color.theme.secondaryText)
                        
                        VStack (alignment: .center, spacing: 2) {
                            Text("Maximum")
                                .caption2Title()
                                .padding(2)
                                .frame(maxWidth: .infinity)
                                .background(Color.white)
                                .cornerRadius(2)
                            
                            if let safeMaxDose = maxDose, let safeMaxInfusion = maxInfusion {
                                Text("\(safeMaxDose) \(getInfusionDoseFactor().rawValue)")
                                    .font(.system(size: 13, weight: .light))
                                
                                Text("\(safeMaxInfusion) ml/h")
                                    .font(.system(size: 14, weight: .bold))
                            }
                        }
                        .fixedSize()
                    }
                    .foregroundColor(Color("Text"))
                }
                
            } else {
                VStack (alignment: .leading, spacing: 0) {
                    Text("Dose Range")
                        .captionTitle()
                        .frame(maxWidth: .infinity, alignment: .center)
                        
                    
                    HStack {
                        VStack (alignment: .center, spacing: 2) {
                            Text("Mininum")
                                .caption2Title()
                                .padding(2)
                                .frame(maxWidth: .infinity)
                                .background(Color.white)
                                .cornerRadius(2)
                            
                            if let safeMinDose = minDose, let safeMinInfusion = minInfusion {
                                Text("\(safeMinDose) \(getPushDoseFactor().rawValue)")
                                    .font(.system(size: 12, weight: .light))
                                
                                Text("\(safeMinInfusion) ml")
                                    .font(.system(size: 14, weight: .bold))
                            }
                            
                        }
                        .fixedSize(horizontal: true, vertical: false)
                        
                        Image(systemName: "circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(Color.theme.secondaryText)
                        
                        Rectangle()
                            .frame(maxWidth: .infinity)
                            .frame(height: 1)
                        
                        Image(systemName: "circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(Color.theme.secondaryText)
                        
                        VStack (alignment: .center, spacing: 2) {
                            Text("Maximum")
                                .caption3Title()
                                .padding(2)
                                .frame(maxWidth: .infinity)
                                .background(Color.white)
                                .cornerRadius(2)
                            
                            if let safeMaxDose = maxDose, let safeMaxInfusion = maxInfusion {
                                Text("\(safeMaxDose) \(getPushDoseFactor().rawValue)")
                                    .font(.system(size: 12, weight: .light))
                                
                                Text("\(safeMaxInfusion) ml")
                                    .font(.system(size: 14, weight: .bold))
                            }
                        }
                        .fixedSize()
                    }
                    .foregroundColor(Color("Text"))
                }
            }
        }
        
        
    }
    
    func getPushDoseFactor() -> PushDoseOptions {
        
        if let safeFactor = solution.solutionEntity?.min_max_factor {
            if safeFactor == 0 {
                return .mg
            } else if safeFactor == 1 {
                return .mgKg
            } else if safeFactor == 5 {
                return .unitsKg
            } else {
                return .mg
            }
        } else {
            fatalError()
        }
        
    }
    
    func getInfusionDoseFactor() -> ConcentrationOptions {
        if let safeFactor = solution.solutionEntity?.min_max_factor, let safeUnit = solution.solutionEntity?.drug_weight_unit {
            if safeUnit == 1 {
                return .unitsMin
            } else {
                if safeFactor == 2 {
                    return .mgMin
                } else if safeFactor == 3 {
                    return .mcgKgMin
                } else if safeFactor == 4 {
                    return .unitsMin
                } else {
                    return .mgMin
                }
            }
            
        } else {
            fatalError()
        }
    }
    
    func getDoseRangeStep() -> Double {
        if let safeMin = solution.minDose, let safeMax = solution.maxDose {
            let range = (safeMax - safeMin)/20
            let f = floor(range)
            return f + round((range - f) * 20)/20
            
        } else {
            return 0.0
        }
    }
    
    func getInfusionRangeStep() -> Double {
        if let safeMin = solution.minDose, let safeMax = solution.maxDose {
            let range = safeMax - safeMin
            return range/20
            
        } else {
            return 0.0
        }
    }
    
    func getInfusionRateString(value: Double) -> String {
        if let safeDoseOption = doseOption {
            let infusionRate = InfusionCalculator.getInfusionRate(desiredInfusionRate: value, inputRateMethod: safeDoseOption, solutionConcentrationMgMl: solutionConcentration, patientWeight: patientWeight, outputRateMethod: .mlHour)
            return NumberModel(value: infusionRate, numberType: .infusionRate).description
        } else {
            return "error"
        }
        
    }
    
    func getPushDoseString(value: Double) -> String {
        if let safeDoseOption = doseOption {
            let pushDose = InfusionCalculator.getPushDose(desiredPushDose: value, inputDoseOption: safeDoseOption, solutionConcentrationMgMl: solutionConcentration, patientWeight: patientWeight)
            
            return NumberModel(value: pushDose, numberType: .infusionRate).description
        } else {
            return "error push dose"
        }
        
    }
    
    @ViewBuilder
    var horizontalRangeView: some View {
        
        if showHorizontalRange {
            if solution.solutionType == 1 {
                ScrollView (.horizontal, showsIndicators: false) {
                    HStack {
                        VStack (alignment: .trailing, spacing: 2) {
                            Text("\(getInfusionDoseFactor().rawValue)")
                                .font(.system(size: 12, weight: .light))
                                .padding(2)
                                .frame(maxWidth: .infinity)
                                .background(Color.white.opacity(0.6))
                                .cornerRadius(2)
                            
                            Spacer()
                                .frame(height: 5)
                            
                            Text("ml/h")
                                .font(.system(size: 12, weight: .light))
                                .padding(2)
                                .frame(maxWidth: .infinity)
                                .background(Color.white.opacity(0.6))
                                .cornerRadius(2)
                        }
                        
                            .font(.system(size: 12, weight: .light))
                        if let safeMin = solution.minDose, let safeMax = solution.maxDose {
                            ForEach(0..<20, id: \.self) { index in
                                let doseStep = safeMin + getDoseRangeStep()*Double(index)
                                VStack (spacing: 2) {
                                    Text("\(NumberModel(value: doseStep, numberType: .dose).description)")
                                        .font(.system(size: 14, weight: .light))
                                    
                                    Rectangle().fill(Color.gray.opacity(0.4))
                                        .frame(width: 1, height: 9)
                                        
                                    Text("\(getInfusionRateString(value: doseStep))")
                                        .font(.system(size: 14, weight: .light))
                                }
                            }
                        }
                        
                    }
                    .foregroundColor(Color.theme.primaryText)
                    
                }
            } else {
                ScrollView (.horizontal, showsIndicators: false) {
                    HStack {
                        VStack (alignment: .trailing, spacing: 2) {
                            Text("\(getPushDoseFactor().rawValue)")
                                .font(.system(size: 12, weight: .light))
                                .padding(2)
                                .frame(maxWidth: .infinity)
                                .background(Color.white.opacity(0.6))
                                .cornerRadius(2)
                            
                            Spacer()
                                .frame(height: 5)
                            
                            Text("ml")
                                .font(.system(size: 12, weight: .light))
                                .padding(2)
                                .frame(maxWidth: .infinity)
                                .background(Color.white.opacity(0.6))
                                .cornerRadius(2)
                        }
                        
                            .font(.system(size: 12, weight: .light))
                        if let safeMin = solution.minDose, let safeMax = solution.maxDose {
                            ForEach(0..<20, id: \.self) { index in
                                let doseStep = safeMin + getDoseRangeStep()*Double(index)
                                VStack (spacing: 2) {
                                    Text("\(String(format: "%.2f", doseStep))")
                                        .font(.system(size: 14, weight: .light))
                                    
                                    Rectangle().fill(Color.gray.opacity(0.4))
                                        .frame(width: 1, height: 9)
                                        
                                    Text("\(getPushDoseString(value: doseStep))")
                                        .font(.system(size: 14, weight: .light))
                                }
                            }
                        }
                        
                    }
                    .foregroundColor(Color.theme.primaryText)
                    
                }
            }
        }
        
        
        
    }
}

struct ListDetailComponent_Previews: PreviewProvider {
    @State var solution = SolutionListClass.testData
    static var previews: some View {
        ListDetailComponent(solution: SolutionListClass.testData, patientWeight: 68.0)
            
    }
}
