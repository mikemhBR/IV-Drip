//
//  ContentView.swift
//  IV Drip
//
//  Created by Michael Mattesco Horta on 13/08/23.
//

import SwiftUI
import CoreData

struct ContentView: View {
    
    @EnvironmentObject var navigationModel: NavigationModel
    
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CustomSolutionEntity.solution_name, ascending: true)],
        animation: .default)
    private var items: FetchedResults<CustomSolutionEntity>

    var body: some View {
        ZStack {
            switch navigationModel.selectedModal {
            case .homeView:
                HomeView()
            case .calculatorView:
                CalculatorView()
            case .mySolutions:
                MySolutionsView()
            case .addCustomSolution:
                AddCustomSolutionView()
            case .addMedication:
                AddMedView()
            case .myLists:
                MyListsView()
            case .createNewList:
                CreateListView()
            }
            
        }
        
    }

    private func addItem() {
        withAnimation {
            let newItem = CustomSolutionEntity(context: viewContext)
            newItem.solution_name = "kajdfljaj"

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(NavigationModel.shared)
            
    }
}
