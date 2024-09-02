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
    let persistenceController = CoreDataManager.shared
    @ObservedObject var userPreferences = UserPreferences()

    init() {
        ColorTransformer.register()
        // Any additional initialization if needed
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.viewContext)
                .environmentObject(userPreferences)
                .onOpenURL { url in
                    handleURL(url)
                }
            
        }
    }

    private func handleURL(_ url: URL) {
        if url.scheme == "myapp" && url.host == "createEntryWithStamp" {
            if let stampIdString = url.queryParameters?["stampId"], let stampId = UUID(uuidString: stampIdString) {
                NotificationCenter.default.post(name: NSNotification.Name("CreateEntryWithStamp"), object: stampId)
            }
        }
    }
}



