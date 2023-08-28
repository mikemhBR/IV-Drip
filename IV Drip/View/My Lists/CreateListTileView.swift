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
    
    var doseRangeView: some View {
        VStack (alignment: .leading, spacing: 0) {
            Text("Dose Range")
                
            
            HStack {
                VStack (alignment: .leading) {
                    Text("Mininum")
                        .caption3Title()
                    Text("0.1mcg/kg/min")
                        .font(.system(size: 14))
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
                
                VStack (alignment: .leading) {
                    Text("Maximum")
                        .caption3Title()
                    Text("0.1mcg/kg/min")
                        .font(.system(size: 14))
                }
                .fixedSize()
            }
            
        }
        .foregroundColor(Color("Text"))
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
