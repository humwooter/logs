//
//  entry_1App.swift
//  entry-1
//
//  Created by Katya Raman on 8/14/23.
//

import SwiftUI
import TipKit


//public class TabSelectionInfo: ObservableObject {
//    @Published public var selectedIndex: Int = 0
//    @Published public var tabJustTapped: Bool = false
//    @Published public var isRootTabView: Bool = false
//
//}


@main
struct entry_1App: App {
    // let persistenceController = PersistenceController.shared
    let persistenceController = CoreDataManager.shared
//    @ObservedObject  var tabSelectionInfo = TabSelectionInfo()
    
    init() {
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView().environment(\.managedObjectContext, persistenceController.viewContext)
//                .environmentObject(tabSelectionInfo)

            // ContentView().environment(\.managedObjectContext, CoreDataManager.shared.persistentContainer.viewContext)
//            ContentView()
//                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}



