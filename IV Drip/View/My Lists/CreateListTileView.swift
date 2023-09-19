//
//  CreateListTileView.swift
//  IV Drip
//
//  Created by Michael Mattesco Horta on 28/08/23.
//

import SwiftUI

struct CreateListTileView: View {
    
    let solution: SolutionListClass
    
    @Binding var isSelected: Bool
    
    let mainComponentWeightString: String
    let numberAmpsString: String
    let dilutionVolumeString: String
    let finalWeightString: String
    let finalVolumeString: String
    let unitOfMeasure: String
    
    init(solution: SolutionListClass, isSelected: Binding<Bool>) {
        self.solution = solution
        self._isSelected = isSelected
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
    
    func getMinimumDose() {
        
    }
    
    @ViewBuilder
    var doseRangeView: some View {
        
        
        if let safeSolution = solution.solutionEntity {
            let minDose = safeSolution.solution_min
            let maxDose = safeSolution.solution_max
            
            
            
            if safeSolution.solution_type == 1 {
                let testMinimum = DatabaseInfusionDoseStruct(initialValue: minDose, databaseUnitOfMeasure: Int(safeSolution.min_max_factor))
                
                let testMaximum = DatabaseInfusionDoseStruct(initialValue: maxDose, databaseUnitOfMeasure: Int(safeSolution.min_max_factor))
                
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
                            
                            Text("\(String(format: "%.2f", testMinimum.drugDose)) \(testMinimum.unitOfMeasure.rawValue)")
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
                            
                            Text("\(String(format: "%.2f", testMaximum.drugDose)) \(testMaximum.unitOfMeasure.rawValue)")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Color.theme.primaryText)
                        }
                        .fixedSize()
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

struct CreateListTileView_Previews: PreviewProvider {
    static var previews: some View {
        CreateListTileView(solution: SolutionListClass.testData, isSelected: .constant(false))
            .environmentObject(NavigationModel.shared)
            .environmentObject(DBBrain.shared)
    }
}
