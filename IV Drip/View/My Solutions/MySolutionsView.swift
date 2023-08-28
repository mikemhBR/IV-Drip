//
//  MySolutionsView.swift
//  IV Drip
//
//  Created by Michael Mattesco Horta on 13/08/23.
//

import SwiftUI

struct SolutionListClass: Identifiable {
    let id = UUID()
    var solutionEntity: CustomSolutionEntity?
    let solutionName: String
    let solutionType: Int
    let mainComponentName: String
    let mainComponentWeightPerAmp: Double
    let volumePerAmp: Double
    let numberAmps: Double
    let dilutionVolume: Double
    var isSelected = false
    
    init(solutionEntity: CustomSolutionEntity) {
        self.solutionEntity = solutionEntity
        self.solutionName = solutionEntity.solution_name ?? ""
        self.solutionType = Int(solutionEntity.solution_type)
        self.mainComponentName = solutionEntity.main_active ?? ""
        self.mainComponentWeightPerAmp = solutionEntity.drug_weight_amp
        self.volumePerAmp = solutionEntity.drug_volume_amp
        self.numberAmps = solutionEntity.amp_number
        self.dilutionVolume = solutionEntity.dilution_volume
    }
    
    init(solutionName: String, solutionType: Int, mainComponentName: String, mainComponentWeightPerAmp: Double, volumePerAmp: Double, numberAmps: Double, dilutionVolume: Double) {
        self.solutionName = solutionName
        self.solutionType = solutionType
        self.mainComponentName = mainComponentName
        self.mainComponentWeightPerAmp = mainComponentWeightPerAmp
        self.volumePerAmp = volumePerAmp
        self.numberAmps = numberAmps
        self.dilutionVolume = dilutionVolume
    }
    
    static var testData = SolutionListClass(solutionName: "Dobutamine Drip", solutionType: 1, mainComponentName: "Dobutamine", mainComponentWeightPerAmp: 250.0, volumePerAmp: 20.0, numberAmps: 4, dilutionVolume: 170.0)
}

class MySolutionsViewModel: ObservableObject {
    var dbBrain = DBBrain.shared
    
    @Published var solutionList = [SolutionListClass]()
    @Published var medicationList = [MedicationEntity]()
    @Published var selectedSolution: SolutionListClass?
    
    init() {
        getSolutionList()
        getMeds()
    }
    
    func getSolutionList() {
        solutionList = []
        
        var databaseSolutionList = [CustomSolutionEntity]()
        do {
            databaseSolutionList = try dbBrain.getAllSolutionsList()
        } catch {
            fatalError()
        }
        
        for solution in databaseSolutionList {
            solutionList.append(SolutionListClass(solutionEntity: solution))
        }
    }
    
    func deleteSolution(toDelete: CustomSolutionEntity) {
        dbBrain.deleteCustomSolution(toDelete: toDelete)
        getSolutionList()
    }
    
    func getMeds() {
        medicationList = dbBrain.getAllMedications()
    }
    
}

struct MySolutionsView: View {
    @EnvironmentObject var navigationModel: NavigationModel
    @EnvironmentObject var dbBrain: DBBrain
    
    @StateObject private var viewModel = MySolutionsViewModel()
    
    @State private var currentTab = 0
        
    @State private var showSolutionCalculator = false
    
    var body: some View {
        VStack {
            SectionHeaderView(sectionTitle: currentTab == 0 ? "My Solutions" : "My Medications") {
                withAnimation {
                    navigationModel.navigateTo(to: .homeView)
                }
            }
            
            TabView(selection: $currentTab) {
                
                VStack (spacing: 0) {
                    
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
                    
                    List {
                        ForEach(viewModel.solutionList, id: \.id) { solution in
                            SolutionListTileView(solution: solution)
                                .onTapGesture {
                                    
                                    viewModel.selectedSolution = solution
                                    
                                    withAnimation {
                                        showSolutionCalculator = true
                                    }
                                    
                                }
                                .swipeActions {
                                    Button {
                                        if let safeSolution = solution.solutionEntity {
                                            viewModel.deleteSolution(toDelete: safeSolution)
                                        }
                                        
                                        
                                    } label: {
                                        Image(systemName: "trash.circle.fill")
                                    }

                                }
                                .frame(maxWidth: .infinity)
                                .listStyle(PlainListStyle())
                                .listRowBackground(Color.theme.background)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                        }
                        
                        
                    }
                    .scrollContentBackground(.hidden)

                    
                    Spacer()
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.theme.background)
                .tabItem({
                    Label {
                        Text("Solutions")
                    } icon: {
                        Image(systemName: "heart.fill")
                    }
                })
                .tag(0)
                
                VStack {
                    
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
                    
                    List {
                        ForEach(viewModel.medicationList, id: \.self) { med in
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
                            .frame(maxWidth: .infinity)
                            .padding(Constants.Layout.kPadding/2)
                            .background(Color.theme.rowBackground)
                            .cornerRadius(Constants.Layout.cornerRadius.small.rawValue)
                            .listStyle(PlainListStyle())
                            .listRowBackground(Color.theme.background)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                            
                        }
                        
                        
                    }
                    .scrollContentBackground(.hidden)
                    .frame(maxWidth: .infinity)
                    
                    
                    Spacer()
                    
                }
                .background(Color.theme.background)
                .tabItem({
                    Label {
                        Text("Meds")
                    } icon: {
                        Image(systemName: "heart.fill")
                    }
                    
                })
                .tag(1)
                
                
            }
        }
        .padding(.horizontal, Constants.Layout.kPadding/2)
        .background(Color.theme.background)
        
        .fullScreenCover(isPresented: $showSolutionCalculator) {
            if let safeSolution = viewModel.selectedSolution {
                MySolutionCalculatorView(selectedSolution: safeSolution)
            }
            
        }
    }
    
    
}

struct MySolutionsView_Previews: PreviewProvider {
    static var previews: some View {
        MySolutionsView()
            .environmentObject(NavigationModel.shared)
            .environmentObject(DBBrain.shared)
    }
}
