//
//  entry_1App.swift
//  entry-1
//
//  Created by Katya Raman on 8/14/23.
//

import SwiftUI
import TipKit

@main
struct entry_1App: App {
    // let persistenceController = PersistenceController.shared
    let persistenceController = CoreDataManager.shared

    
    init() {
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView().environment(\.managedObjectContext, persistenceController.viewContext)

            // ContentView().environment(\.managedObjectContext, CoreDataManager.shared.persistentContainer.viewContext)
//            ContentView()
//                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
