//
//  IV_DripApp.swift
//  IV Drip
//
//  Created by Michael Mattesco Horta on 13/08/23.
//

import SwiftUI

@main
struct IV_DripApp: App {
    let persistenceController = PersistenceController.shared

    @StateObject private var navigationModel = NavigationModel.shared
    @StateObject private var dbBrain = DBBrain.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(navigationModel)
                .environmentObject(dbBrain)
        }
    }
}
