//
//  CreateListTileView.swift
//  IV Drip
//
//  Created by Michael Mattesco Horta on 28/08/23.
//

import SwiftUI

struct CreateListTileView: View {
    
    let solution: SolutionListClass
    
    @State private var isSelected = false
    
    let wasSelected: (_: Bool) -> ()
    
    let mainComponentWeightString: String
    let numberAmpsString: String
    let dilutionVolumeString: String
    let finalWeightString: String
    let finalVolumeString: String
    let unitOfMeasure: String
    
    init(solution: SolutionListClass, wasSelected: @escaping (_: Bool) -> Void) {
        self.solution = solution
        self.wasSelected = wasSelected
        self.mainComponentWeightString = String(format: "%.1f", solution.mainComponentWeightPerAmp)
        self.numberAmpsString = String(format: "%.1f", solution.numberAmps)
        self.dilutionVolumeString = String(format: "%.1f", solution.dilutionVolume)
        self.finalWeightString = String(format: "%.1f", solution.mainComponentWeightPerAmp*solution.numberAmps)
        self.finalVolumeString = String(format: "%.1f", (solution.volumePerAmp*solution.numberAmps) + solution.dilutionVolume)
        self.unitOfMeasure = solution.solutionEntity?.drug_weight_unit == 0 ? "mg" : "units"
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
        .background(isSelected ? Color("Accent Blue").opacity(0.3) : Color("Row Background"))
        .cornerRadius(Constants.Layout.cornerRadius.small.rawValue)
        .onTapGesture {
            withAnimation {
                isSelected.toggle()
            }
            wasSelected(isSelected)
        }
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
            let databaseRateFactor = Int(safeSolution.min_max_factor)
            let minDose = safeSolution.solution_min
            let maxDose = safeSolution.solution_max
            
            
            if safeSolution.solution_type == 1 {
                
                let desiredOutputFactor = getInfusionDoseFactor(factor: databaseRateFactor)
                
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
                                
                                if let safeMin = InfusionCalculator.normalizeDatabaseInfusionDose(rateValue: minDose, databaseRateFactor: databaseRateFactor, desiredOutputFactor: desiredOutputFactor) {
                                    Text("\(String(format: "%.2f", safeMin)) \(desiredOutputFactor.rawValue)")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(Color.theme.primaryText)
                                } else {
                                    Text("not assigned")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(Color.theme.secondaryText)
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
                                
                                if let safeMax = InfusionCalculator.normalizeDatabaseInfusionDose(rateValue: maxDose, databaseRateFactor: databaseRateFactor, desiredOutputFactor: desiredOutputFactor) {
                                    Text("\(String(format: "%.2f", safeMax)) \(desiredOutputFactor.rawValue)")
                                        .font(.system(size: 12, weight: .semibold))
                                } else {
                                    Text("not assigned")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(Color.theme.secondaryText)
                                }
                            }
                            .fixedSize()
                        }
                        
                    }
                
                
                
                
                
            } else {
                let desiredOutputFactor = getPushDoseFactor(factor: databaseRateFactor)
                
                
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
                                
                                if let safeMin = InfusionCalculator.normalizeDatabasePushDose(rateValue: minDose, databaseRateFactor: databaseRateFactor, desiredOutputFactor: desiredOutputFactor) {
                                    Text("\(String(format: "%.2f", safeMin)) mcg/kg/min")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(Color.theme.primaryText)
                                } else {
                                    Text("not assigned")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(Color.theme.secondaryText)
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
                                
                                if let safeMax = InfusionCalculator.normalizeDatabasePushDose(rateValue: maxDose, databaseRateFactor: databaseRateFactor, desiredOutputFactor: desiredOutputFactor) {
                                    Text("\(String(format: "%.2f", safeMax)) mcg/kg/min")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(Color.theme.primaryText)
                                    
                                } else {
                                    Text("not assigned")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(Color.theme.secondaryText)
                                }
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

struct CreateListTileView_Previews: PreviewProvider {
    static var previews: some View {
        CreateListTileView(solution: SolutionListClass.testData) { isSelected in
            
        }
        .environmentObject(NavigationModel.shared)
        .environmentObject(DBBrain.shared)
    }
}
