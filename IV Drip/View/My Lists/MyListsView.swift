//
//  MyListsView.swift
//  IV Drip
//
//  Created by Michael Mattesco Horta on 28/08/23.
//

import SwiftUI

class MyListsViewModel: ObservableObject {
    var dbBrain = DBBrain.shared
    
    @Published var myLists = [SolutionListEntity]()
    @Published var selectedList: SolutionListEntity?
    
    init() {
        getAllLists()
    }
    
    func getAllLists() {
        try? myLists = dbBrain.getAllLists()
    }
    
    func deleteList(listUUID: String) {
        dbBrain.deleteList(listUUID: listUUID)
        getAllLists()
    }
    
}
struct MyListsView: View {
    @EnvironmentObject var navigationModel: NavigationModel
    
    @StateObject private var viewModel = MyListsViewModel()
    
    @State private var showDetailView = false
    @State private var selectedList: SolutionListEntity?
    
    var body: some View {
        VStack {
            SectionHeaderView(sectionTitle: "My Lists") {
                withAnimation {
                    navigationModel.navigateTo(to: .homeView)
                }
            }
            
            Button {
                withAnimation {
                    navigationModel.navigateTo(to: .createNewList)
                }
            } label: {
                Label {
                    Text("Create List")
                } icon: {
                    Image(systemName: "plus")
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            
            List {
                ForEach(viewModel.myLists, id: \.self) { list in
                    Text(list.list_name ?? "")
                        .onTapGesture {
                            
                            viewModel.selectedList = list
                            
                            //TODO: remove
                            var testList = list.listToFact as? Set<SolutionListFact>
                            
                            for object in testList! {
                                let singleObject = object.factToSolution
                                print(singleObject?.solution_name)
                            }
                            
                            withAnimation {
                                showDetailView = true
                            }
                            
                        }
                        .listRowBackground(Color.theme.rowBackground)
                        .swipeActions {
                            Button {
                                if let safeUUID = list.list_uuid {
                                    viewModel.deleteList(listUUID: safeUUID)
                                }
                                
                            } label: {
                                Image(systemName: "trash.circle.fill")
                            }
                        }
                }
                
            }
            .scrollContentBackground(.hidden)
        }
        .fullScreenCover(isPresented: $showDetailView) {
            if let safeList = viewModel.selectedList {
                ListDetailView(selectedList: safeList)
            }
                
        }
        .padding(.horizontal, Constants.Layout.kPadding/2)
        .background(Color.theme.background)
        
    }
}

struct MyListsView_Previews: PreviewProvider {
    static var previews: some View {
        MyListsView()
    }
}
