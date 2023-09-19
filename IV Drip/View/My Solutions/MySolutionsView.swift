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
    
    //TODO: check if minDose and maxDose can be "let"
    var minDose: Double?
    var maxDose: Double?
    var isSelected: Bool
    
    init(solutionEntity: CustomSolutionEntity, isSelected: Bool = false) {
        self.solutionEntity = solutionEntity
        self.solutionName = solutionEntity.solution_name ?? ""
        self.solutionType = Int(solutionEntity.solution_type)
        self.mainComponentName = solutionEntity.main_active ?? ""
        self.mainComponentWeightPerAmp = solutionEntity.drug_weight_amp
        self.volumePerAmp = solutionEntity.drug_volume_amp
        self.numberAmps = solutionEntity.amp_number
        self.dilutionVolume = solutionEntity.dilution_volume
        
        if solutionEntity.solution_min > 0.0 {
            self.minDose = solutionEntity.solution_min
        } else {
            self.minDose = nil
        }
        if solutionEntity.solution_max > 0.0 {
            self.maxDose = solutionEntity.solution_max
        } else {
            self.maxDose = nil
        }
        
        self.isSelected = isSelected
    }
    
    init(solutionName: String, solutionType: Int, mainComponentName: String, mainComponentWeightPerAmp: Double, volumePerAmp: Double, numberAmps: Double, minDose: Double? = nil, maxDose: Double? = nil, dilutionVolume: Double, isSelected: Bool = false) {
        self.solutionName = solutionName
        self.solutionType = solutionType
        self.mainComponentName = mainComponentName
        self.mainComponentWeightPerAmp = mainComponentWeightPerAmp
        self.volumePerAmp = volumePerAmp
        self.numberAmps = numberAmps
        self.dilutionVolume = dilutionVolume
        self.minDose = minDose
        self.maxDose = maxDose
        self.isSelected = isSelected
    }
    
    static var testData = SolutionListClass(solutionName: "Norepinephrine Drip", solutionType: 1, mainComponentName: "Norepinephrine", mainComponentWeightPerAmp: 4.0, volumePerAmp: 4.0, numberAmps: 4, minDose: 0.05, maxDose: 1.0, dilutionVolume: 234.0)
    
    static var testDataDobutamine = SolutionListClass(solutionName: "Dobutamine Drip", solutionType: 1, mainComponentName: "Dobutamine", mainComponentWeightPerAmp: 250.0, volumePerAmp: 20.0, numberAmps: 4, minDose: 5.0, maxDose: 20.0, dilutionVolume: 170.0)
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
    private enum PresentedSheet: Identifiable {
        case calculatorView, editSolution, editMedication
        
        var id: PresentedSheet {
            self
        }
    }
    
    @EnvironmentObject var navigationModel: NavigationModel
    @EnvironmentObject var dbBrain: DBBrain
    
    @StateObject private var viewModel = MySolutionsViewModel()
    
    @State private var currentTab = 0
        
    @State private var editSolutionsActive = false
    
    @State private var presentedSheet: PresentedSheet?
    
    var body: some View {
        VStack {
            SectionHeaderView(sectionTitle: currentTab == 0 ? "My Solutions" : "My Medications") {
                withAnimation {
                    navigationModel.navigateTo(to: .homeView)
                }
            }
            
            TabView(selection: $currentTab) {
                
                VStack (spacing: 0) {
                    HStack {
                        Button {
                            withAnimation {
                                editSolutionsActive.toggle()
                            }
                        } label: {
                            Text("Edit Solutions")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color("Accent Red"))
                        }
                        
                        Spacer()
                        
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
                    }
                    
                    if viewModel.solutionList.isEmpty {
                        Text("No saved solutions")
                            .captionTitle()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(Constants.Layout.kPadding)
                        
                        Spacer()
                        
                    } else {
                        List {
                            ForEach(viewModel.solutionList, id: \.id) { solution in
                                HStack (spacing: Constants.Layout.kPadding/2) {
                                    if editSolutionsActive {
                                        Image(systemName: "circle.fill")
                                            .foregroundColor(Color("Accent Red"))
                                    }
                                    SolutionListTileView(solution: solution)
                                        .onTapGesture {
                                            
                                            viewModel.selectedSolution = solution
                                            
                                            if !editSolutionsActive {
                                                withAnimation {
                                                    presentedSheet = .calculatorView
                                                }
                                            } else {
                                                presentedSheet = .editSolution
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
                                        
                                }
                                
                            }
                            .listStyle(PlainListStyle())
                            .listRowBackground(Color.theme.background)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                            
                        }
                        .scrollContentBackground(.hidden)
                    }
                    
                    
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
        .fullScreenCover(item: $presentedSheet, onDismiss: {
            withAnimation {
                editSolutionsActive = false
            }
            viewModel.getSolutionList()
        }, content: { sheet in
            switch sheet {
            case .calculatorView:
                if let safeSolution = viewModel.selectedSolution {
                    MySolutionCalculatorView(selectedSolution: safeSolution)
                }
            case .editSolution:
                if let safeSolution = viewModel.selectedSolution?.solutionEntity {
                    EditSolutionView(solution: safeSolution)
                }
                
            case .editMedication:
                Color.blue
            
            }
        })
        
        
    }
    
    
}

struct MySolutionsView_Previews: PreviewProvider {
    static var previews: some View {
        MySolutionsView()
            .environmentObject(NavigationModel.shared)
            .environmentObject(DBBrain.shared)
    }
}
