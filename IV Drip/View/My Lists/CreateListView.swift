//
//  CreateListView.swift
//  IV Drip
//
//  Created by Michael Mattesco Horta on 28/08/23.
//

import SwiftUI

class CreateListViewModel: ObservableObject {
    @Published var solutionList = [SolutionListClass]()
    @Published var listName = "List Name"
    
    var dbBrain = DBBrain.shared
    
    init() {
        getSolutionList()
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
    
    func saveList() throws {
        var newList = [SolutionListClass]()
        
        let listUUID = UUID().uuidString
        
        var createdList: SolutionListEntity?
        
        do {
            try createdList = dbBrain.createNewList(listName: listName, listUUID: listUUID)
        } catch {
            throw DatabaseError.saveNewListError
        }
        
        for solution in solutionList {
            guard let safeSolution = solution.solutionEntity, let safeList = createdList else { fatalError() }
            if solution.isSelected {
                do {
                    try dbBrain.saveSolutionToList(list: safeList, solution: safeSolution)
                } catch {
                    fatalError()
                }
            }
        }
    }
}

struct CreateListView: View {
    @EnvironmentObject var navigationModel: NavigationModel
    @EnvironmentObject var dbBrain: DBBrain
    
    @StateObject private var viewModel = CreateListViewModel()
    
    @State private var listName = "List Name"
    @FocusState private var nameIsFocused
    
    var body: some View {
        VStack {
            SectionHeaderView(sectionTitle: "Create List") {
                withAnimation {
                    navigationModel.navigateTo(to: .myLists)
                }
            }
            
            TextField("List Name", text: $viewModel.listName)
                .font(.system(size: 14))
                .foregroundColor(Color.theme.primaryText)
                .frame(height: 44)
                .focused($nameIsFocused)
                .padding(.horizontal, Constants.Layout.kPadding/2)
                .background(Color.white)
                .cornerRadius(Constants.Layout.cornerRadius.small.rawValue)
            
            List {
                ForEach($viewModel.solutionList, id: \.id) { $solution in
                    CreateListTileView(solution: solution) { wasSelected in
                        solution.isSelected = wasSelected
                    }
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
                    try viewModel.saveList()
                } catch {
                    print("error")
                }
                
                navigationModel.navigateTo(to: .myLists)
                
            } label: {
                Text("Save")
                    .frame(width: Constants.Layout.buttonWidth.large.rawValue)
                    .modifier(PrimaryButtonConfig())
            }

            
        }
        .padding(.horizontal, Constants.Layout.kPadding)
        .background(Color.theme.background)
    }
    
    
}

struct CreateListView_Previews: PreviewProvider {
    static var previews: some View {
        CreateListView()
    }
}
