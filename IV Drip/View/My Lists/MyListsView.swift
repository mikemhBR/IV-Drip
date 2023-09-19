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
    
    private enum ActiveSheet: Identifiable {
        case editList, showListDetails
        
        var id: ActiveSheet {
            self
        }
    }
    
    @EnvironmentObject var navigationModel: NavigationModel
    
    @StateObject private var viewModel = MyListsViewModel()
    
    @State private var selectedList: SolutionListEntity?
    
    @State private var presentedSheet: ActiveSheet?
    
    var body: some View {
        VStack {
            SectionHeaderView(sectionTitle: "My Lists") {
                withAnimation {
                    navigationModel.navigateTo(to: .homeView)
                }
            }
            
            Spacer()
                .frame(height: Constants.Layout.kPadding)
            
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
                    HStack (spacing: Constants.Layout.kPadding/2) {
                        
                        
                        Text(list.list_name ?? "")
                            
                    }
                    .onTapGesture {
                        
                        viewModel.selectedList = list
                        
                        presentedSheet = .showListDetails
                        
                       
                        
                        
                    }
                    .listRowBackground(Color.theme.rowBackground)
                    .swipeActions (edge: .trailing, allowsFullSwipe: true) {
                        Button {
                            if let safeUUID = list.list_uuid {
                                viewModel.deleteList(listUUID: safeUUID)
                            }
                            
                        } label: {
                            Image(systemName: "trash.circle.fill")
                                
                        }
                        .tint(Color("Accent Red"))
                    }
                    .swipeActions (edge: .leading, allowsFullSwipe: false){
                        Button {
                            viewModel.selectedList = list
                            
                            withAnimation {
                                presentedSheet = .editList
                            }
                        } label: {
                            Image(systemName: "square.and.pencil.circle.fill")
                        }
                    }
                    
                }
                
            }
            .scrollContentBackground(.hidden)
        }
        .fullScreenCover(item: $presentedSheet, content: { sheet in
            switch sheet {
            case .showListDetails:
                if let safeList = viewModel.selectedList {
                    ListDetailView(selectedList: safeList)
                }
                
            case .editList:
                if let safeList = viewModel.selectedList {
                    EditListView(selectedList: safeList)
                }
            }
        })
        .padding(.horizontal, Constants.Layout.kPadding/2)
        .background(Color.theme.background)
        
    }
}

struct MyListsView_Previews: PreviewProvider {
    static var previews: some View {
        MyListsView()
    }
}
