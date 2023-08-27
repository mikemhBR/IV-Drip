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
    @Published var selectedSolution: SolutionListClass?
    
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
            solutionList.append(SolutionListClass(solutionEntity: solution))
        }
    }
}

struct MySolutionsView: View {
    @EnvironmentObject var navigationModel: NavigationModel
    @EnvironmentObject var dbBrain: DBBrain
    
    @StateObject private var viewModel = MySolutionsViewModel()
    
    @State private var currentTab = 0
    
    @State private var medicationList = [MedicationEntity]()
    
    @State private var showSolutionCalculator = false
    
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
                        .onTapGesture {
                            
                            viewModel.selectedSolution = solution
                            
                            withAnimation {
                                showSolutionCalculator = true
                            }
                            
                        }
                }
                .padding(.horizontal, Constants.Layout.kPadding/2)
                
                Spacer()
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(Constants.Layout.kPadding/2)
            .background(Color("Background 200"))
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
                }
                
                Spacer()
                
            }
            .padding(Constants.Layout.kPadding/2)
            .background(Color("Background 200"))
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
        .fullScreenCover(isPresented: $showSolutionCalculator) {
            if let safeSolution = viewModel.selectedSolution {
                MySolutionCalculatorView(selectedSolution: safeSolution)
            }
            
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
