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
    
    @AppStorage(Constants.AppStorage.patientWeight) var storedPatientWeight = 0.0
    
    let selectedList: SolutionListEntity
    
    @State private var patientWeight = 0.0
    @State private var initialWeight = 0
    
    @State private var solutionList = [SolutionListClass]()
    
    var body: some View {
        VStack {
            SectionHeaderView(sectionTitle: "My Lists") {
                withAnimation {
                    navigationModel.navigateTo(to: .myLists)
                }
            }
            
            HorizontalWheelPicker(viewPadding: Constants.Layout.kPadding/2, initialWeight: initialWeight, patientWeight: $patientWeight)
            VStack {
                ForEach(solutionList) { solution in
                    SolutionListTileView(solution: solution)
                }
            }
            
            
            Spacer()
            
        }
        .padding(.horizontal, Constants.Layout.kPadding/2)
        .background(Color.theme.background)
        .onAppear {
            DispatchQueue.main.async {
                initialWeight = Int(storedPatientWeight.rounded(.down))
                patientWeight = Double(initialWeight)
            }
            print("2")
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
