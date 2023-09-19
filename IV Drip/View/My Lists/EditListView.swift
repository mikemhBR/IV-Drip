//
//  EditListView.swift
//  IV Drip
//
//  Created by Michael Mattesco Horta on 01/09/23.
//

import SwiftUI

class EditListViewModel: ObservableObject {
    @Published var solutionList = [SolutionListClass]()
    @Published var listName = "<insert list name>"
    
    private var initialSolutionList = [CustomSolutionEntity]()
    
    var dbBrain = DBBrain.shared
    
    init() {
        
    }
    
    func getInitialSolutionList(list: SolutionListEntity) {
        var allSolutions = [CustomSolutionEntity]()
        
        do {
            allSolutions = try dbBrain.getAllSolutionsList()
        } catch {
            fatalError()
        }
        
        var listSolutions = [CustomSolutionEntity]()
                
        let databaseFactList = list.listToFact as? Set<SolutionListFact>
        
        if let safeFactList = databaseFactList {
            for object in safeFactList {
                if let solution = object.factToSolution {
                    listSolutions.append(solution)
                }
            }
        }
        
        
        for solution in allSolutions {
            if listSolutions.contains(solution) {
                initialSolutionList.append(solution)
            }
        }
        
    }
    
    func getSolutionList(list: SolutionListEntity) {
        
        var allSolutions = [CustomSolutionEntity]()
        
        do {
            allSolutions = try dbBrain.getAllSolutionsList()
        } catch {
            fatalError()
        }
        
        var listSolutions = [CustomSolutionEntity]()
                
        let databaseFactList = list.listToFact as? Set<SolutionListFact>
        
        if let safeFactList = databaseFactList {
            for object in safeFactList {
                if let solution = object.factToSolution {
                    listSolutions.append(solution)
                }
            }
        }
        
        
        for solution in allSolutions {
            if listSolutions.contains(solution) {
                solutionList.append(SolutionListClass(solutionEntity: solution, isSelected: true))
            } else {
                solutionList.append(SolutionListClass(solutionEntity: solution, isSelected: false))
            }
        }
        
    }
    
    func saveList(list: SolutionListEntity) throws {
          
        list.list_name = listName
        
        for solution in solutionList {
            guard let safeSolution = solution.solutionEntity else { fatalError() }
            print(solution.solutionName)
            print(solution.isSelected)
            print(initialSolutionList.contains(safeSolution))
            
            if solution.isSelected && !initialSolutionList.contains(safeSolution){
                do {
                    try dbBrain.saveSolutionToList(list: list, solution: safeSolution)
                    print("new ran")
                } catch {
                    fatalError()
                }
            } else if !solution.isSelected {
                
                dbBrain.removeSolutionFromList(list: list, solution: safeSolution)
                
            }
        }
    }
    
    func adjustList(list: SolutionListEntity, solution: SolutionListClass, wasAdded: Bool) {
        if let safeSolution = solution.solutionEntity {
            if wasAdded {
                do {
                    try dbBrain.saveSolutionToList(list: list, solution: safeSolution)
                } catch {
                    fatalError()
                }
            } else {
                
            }
        }
        
        
    }
}

struct EditListView: View {
    
    @EnvironmentObject var navigationModel: NavigationModel
    @EnvironmentObject var dbBrain: DBBrain
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var viewModel = EditListViewModel()
    
    let selectedList: SolutionListEntity
    
    @State private var listName = "List Name"
    @FocusState private var nameIsFocused
    
    var body: some View {
        VStack (spacing: 0) {
            SectionHeaderView(sectionTitle: "Edit List") {
                withAnimation {
                    dismiss()
                }
            }
            
            Spacer()
                .frame(height: Constants.Layout.kPadding)
            
            Text("List Name")
                .sectionHeaderStyle()
                .frame(maxWidth: .infinity, alignment: .leading)
            
            TextField("", text: $viewModel.listName)
                .font(.system(size: 14))
                .foregroundColor(Color.theme.primaryText)
                .frame(height: 44)
                .focused($nameIsFocused)
                .padding(.horizontal, Constants.Layout.kPadding/2)
                .background(Color.white)
                .cornerRadius(Constants.Layout.cornerRadius.small.rawValue)
            
            Spacer()
                .frame(height: Constants.Layout.kPadding)
            
            Text("Solutions")
                .sectionHeaderStyle()
                .frame(maxWidth: .infinity, alignment: .leading)
            
            List {
                ForEach($viewModel.solutionList, id: \.id) { $solution in
                    CreateListTileView(solution: solution, isSelected: $solution.isSelected)
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.theme.background)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                }
                
            }
            .listStyle(PlainListStyle())
            .frame(maxWidth: .infinity)
            .background(Color.theme.background)
            .scrollContentBackground(.hidden)
            
            Button {
                do {
                    try viewModel.saveList(list: selectedList)
                } catch {
                    print("error")
                }
                
                dismiss()
                
            } label: {
                Text("Save")
                    .frame(width: Constants.Layout.buttonWidth.large.rawValue)
                    .modifier(PrimaryButtonConfig())
            }

            
        }
        .padding(.horizontal, Constants.Layout.kPadding)
        .background(Color.theme.background)
        .onAppear() {
            viewModel.getSolutionList(list: selectedList)
            viewModel.getInitialSolutionList(list: selectedList)
        }
    }
}
