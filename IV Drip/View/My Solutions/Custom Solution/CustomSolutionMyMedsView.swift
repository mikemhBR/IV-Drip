//
//  CustomSolutionMyMedsView.swift
//  IV Drip
//
//  Created by Michael Mattesco Horta on 22/08/23.
//

import SwiftUI

struct CustomSolutionMyMedsView: View {
    @EnvironmentObject var dbBrain: DBBrain
    
    @Environment(\.dismiss) var dismiss
    
    @State private var medicationList = [MedicationEntity]()
    
    @Binding var selectedMed: MedicationEntity?
    
    var body: some View {
        VStack {
            SectionHeaderView(sectionTitle: "My Meds") {
                dismiss()
            }
            
            ForEach(medicationList, id: \.self) { med in
                VStack (alignment: .leading) {
                    Text(med.med_name ?? "error")
                        .fixedSize()
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color("Text"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("\(String(format: "%.1f", med.med_weight))mg / \(String(format: "%.1f", med.med_volume))ml")
                        .fixedSize()
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Color("Text"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(Constants.Layout.kPadding/2)
                .background(Color("Row Background"))
                .cornerRadius(Constants.Layout.cornerRadius.small.rawValue)
                .padding(.vertical, 2)
                .onTapGesture {
                    selectedMed = med
                    withAnimation {
                        dismiss()
                    }
                }
            }
            
            Spacer()
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(Constants.Layout.kPadding)
        .background(Color("Background 200"))
        .onAppear() {
            medicationList = dbBrain.getAllMedications()
        }
        
    }
}

struct CustomSolutionMyMedsView_Previews: PreviewProvider {
    static var previews: some View {
        CustomSolutionMyMedsView(selectedMed: .constant(nil))
            .environmentObject(NavigationModel.shared)
            .environmentObject(DBBrain.shared)
    }
}
