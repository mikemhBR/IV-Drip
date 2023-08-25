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
                Text(med.med_name ?? "error")
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
        .background(Color.white)
        .padding(Constants.Layout.kPadding)
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
