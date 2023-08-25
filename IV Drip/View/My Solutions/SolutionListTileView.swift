//
//  SolutionListTileView.swift
//  IV Drip
//
//  Created by Michael Mattesco Horta on 25/08/23.
//

import SwiftUI

struct SolutionListTileView: View {
    
    let solution: SolutionListClass
    
    var body: some View {
        let mainComponentWeightString = String(format: "%.1f", solution.mainComponentWeightPerAmp)
        let numberAmpsString = String(format: "%.1f", solution.numberAmps)
        let dilutionVolumeString = String(format: "%.1f", solution.dilutionVolume)
        let finalWeightString = String(format: "%.1f", solution.mainComponentWeightPerAmp*solution.numberAmps)
        let finalVolumeString = String(format: "%.1f", (solution.volumePerAmp*solution.numberAmps) + solution.dilutionVolume)
        
        VStack (alignment: .leading, spacing: 4) {
            HStack {
                Text(solution.solutionName)
                    .font(.system(size: 14, weight: .semibold))
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
            
        }
        .padding(Constants.Layout.kPadding/2)
        .background(Color("Row Background"))
        .cornerRadius(Constants.Layout.cornerRadius.small.rawValue)
    }
}

struct SolutionListTileView_Previews: PreviewProvider {
    static var previews: some View {
        SolutionListTileView(solution: SolutionListClass.testData)
            .environmentObject(NavigationModel.shared)
            .environmentObject(DBBrain.shared)
    }
}
