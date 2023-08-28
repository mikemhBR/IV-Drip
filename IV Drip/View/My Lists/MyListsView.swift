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
                            
                            withAnimation {
                                showDetailView = true
                            }
                            
                        }
                }
                
            }
        }
        .fullScreenCover(isPresented: $showDetailView) {
            if let safeList = viewModel.selectedList {
                
                ListDetailView(selectedList: safeList)
            }
                
        }
        
    }
}

struct MyListsView_Previews: PreviewProvider {
    static var previews: some View {
        MyListsView()
    }
}
