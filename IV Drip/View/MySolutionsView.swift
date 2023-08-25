//
//  MySolutionsView.swift
//  IV Drip
//
//  Created by Michael Mattesco Horta on 13/08/23.
//

import SwiftUI

struct SolutionListClass: Identifiable {
    let id = UUID()
    let solutionName: String
    let solutionType: Int
    let mainComponentName: String
    let mainComponentWeightPerAmp: Double
    let volumePerAmp: Double
    let numberAmps: Double
    let dilutionVolume: Double
    
    static var testData = SolutionListClass(solutionName: "Dobutamine Drip", solutionType: 1, mainComponentName: "Dobutamine", mainComponentWeightPerAmp: 250.0, volumePerAmp: 20.0, numberAmps: 4, dilutionVolume: 170.0)
}

class MySolutionsViewModel: ObservableObject {
    var dbBrain = DBBrain.shared
    
    @Published var solutionList = [SolutionListClass]()
    
    init() {
        getSolutionList()
    }
    
    func getSolutionList() {
        var databaseSolutionList = [CustomSolutionEntity]()
        do {
            databaseSolutionList = try dbBrain.getAllSolutionsList()
        } catch {
            fatalError()
        }
        
        for solution in databaseSolutionList {
            solutionList.append(SolutionListClass(
                solutionName: solution.solution_name ?? "Error",
                solutionType: Int(solution.solution_type),
                mainComponentName: solution.main_active ?? "Error",
                mainComponentWeightPerAmp: solution.drug_weight_amp,
                volumePerAmp: solution.drug_volume_amp,
                numberAmps: solution.amp_number,
                dilutionVolume: solution.dilution_volume))
        }
        
        
        
    }
}

struct MySolutionsView: View {
    @EnvironmentObject var navigationModel: NavigationModel
    @EnvironmentObject var dbBrain: DBBrain
    
    @StateObject private var viewModel = MySolutionsViewModel()
    
    @State private var currentTab = 0
    
    @State private var medicationList = [MedicationEntity]()
    
    var body: some View {
        TabView(selection: $currentTab) {
            
            VStack {
                SectionHeaderView(sectionTitle: "My Solutions") {
                    withAnimation {
                        navigationModel.navigateTo(to: .homeView)
                    }
                }
                
                Button {
                    withAnimation {
                        navigationModel.navigateTo(to: .addCustomSolution)
                    }
                } label: {
                    Label {
                        Text("Create Solution")
                    } icon: {
                        Image(systemName: "plus")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .trailing)

                ForEach(viewModel.solutionList, id: \.id) { solution in
                        SolutionListTileView(solution: solution)
                }
                .padding(.horizontal, Constants.Layout.kPadding/2)
                
                Spacer()
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(Constants.Layout.kPadding/2)
            .tabItem({
                Label {
                    Text("Solutions")
                } icon: {
                    Image(systemName: "heart.fill")
                }
            })
            .tag(0)
            
            VStack {
                SectionHeaderView(sectionTitle: "My Medications") {
                    withAnimation {
                        navigationModel.navigateTo(to: .homeView)
                    }
                }
                
                Button {
                    navigationModel.navigateTo(to: .addMedication)
                } label: {
                    Label {
                        Text("Create Medication")
                    } icon: {
                        Image(systemName: "plus")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .trailing)

                ForEach(medicationList, id: \.self) { med in
                    Text(med.med_name ?? "")
                }
                
                Spacer()
                
            }
            .padding(Constants.Layout.kPadding/2)
            .tabItem({
                Label {
                    Text("Meds")
                } icon: {
                    Image(systemName: "heart.fill")
                }

            })
            .tag(1)
            
            
        }
        .onAppear {
            print("onAppear ran")
            getMeds()
        }
    }
    
    func getMeds() {
        medicationList = dbBrain.getAllMedications()
    }
}

struct MySolutionsView_Previews: PreviewProvider {
    static var previews: some View {
        MySolutionsView()
            .environmentObject(NavigationModel.shared)
            .environmentObject(DBBrain.shared)
    }
}
