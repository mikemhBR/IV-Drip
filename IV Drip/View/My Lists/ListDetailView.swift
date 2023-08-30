//
//  ListDetailView.swift
//  IV Drip
//
//  Created by Michael Mattesco Horta on 28/08/23.
//

import SwiftUI


struct ListDetailView: View {
    @EnvironmentObject var dbBrain: DBBrain
    @EnvironmentObject var navigationModel: NavigationModel
    @Environment(\.dismiss) var dismiss
    
    @AppStorage(Constants.AppStorage.patientWeight) var storedPatientWeight = 0.0
    
    let selectedList: SolutionListEntity
    
    @State private var patientWeight = 0.0
    @State private var initialWeight = 0
    
    @State private var solutionList = [SolutionListClass]()
    
    var body: some View {
        VStack {
            SectionHeaderView(sectionTitle: selectedList.list_name ?? "My List") {
                withAnimation {
                    dismiss()
                }
            }
            
            ScrollView (showsIndicators: false) {
                HorizontalWheelPicker(viewPadding: Constants.Layout.kPadding/2, initialWeight: Int(storedPatientWeight), patientWeight: $patientWeight)
                
                VStack (spacing: Constants.Layout.kPadding){
                    ForEach(solutionList) { solution in
                        ListDetailComponent(solution: solution, patientWeight: patientWeight)
                    }
                }
            }
            
            
        }
        .padding(.horizontal, Constants.Layout.kPadding/2)
        .background(Color.theme.background)
        .onAppear {
            DispatchQueue.main.async {
                initialWeight = Int(storedPatientWeight.rounded(.down))
                patientWeight = Double(initialWeight)
            }
            getSolutions()
        }
        
    }
    
    func getSolutions() {
        var solutionListTemp = [SolutionListClass]()
        
        var databaseList = [CustomSolutionEntity]()
        //TODO: safe unwrap
        databaseList = try! dbBrain.getSolutionsFromList(listUUID: selectedList.list_uuid!)
        
        for solution in databaseList {
            solutionListTemp.append(SolutionListClass(solutionEntity: solution))
        }
        
        DispatchQueue.main.async {
            solutionList = solutionListTemp
        }
    }
}

//struct ListDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        ListDetailView()
//    }
//}
