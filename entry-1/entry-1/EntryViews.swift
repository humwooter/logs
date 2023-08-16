//
//  EntryViews.swift
//  entry-1
//
//  Created by Katya Raman on 8/14/23.
//

import Foundation
import SwiftUI
import CoreData


func formattedDate(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM/dd/yyyy"
    return dateFormatter.string(from: date)
}

class MarkedEntries: ObservableObject {
    @Published var button1_entries: Set<Entry> = []
    @Published var button2_entries: Set<Entry> = []
    @Published var button3_entries: Set<Entry> = []

}


struct EntryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var currentDateFilter = formattedDate(Date())
    @FetchRequest(
        entity: Log.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Log.day, ascending: true)],
        predicate: NSPredicate(format: "day == %@", formattedDate(Date()))
    ) var logs: FetchedResults<Log> // should only be 1 log

    
    @State private var isShowingEntryCreationView = false
//    @State private var importantEntries: Set<Entry> = []

    @ObservedObject var markedEntries = MarkedEntries()

    
    @EnvironmentObject var userPreferences: UserPreferences

    var body: some View {
            NavigationView {
                List {
                    validateDate()
                    if let firstLog = logs.first, firstLog.relationship.count > 0 {
                        let sortedEntries = Array(firstLog.relationship as! Set<Entry>).sorted { $0.time > $1.time }
                        ForEach(sortedEntries, id: \.self) { entry in
                            Section(header: Text(entry.formattedTime()).font(.system(size: UIFont.systemFontSize))) {
                                Text(entry.content)
                                    .font(.custom(String(userPreferences.fontName), size: CGFloat(Float(userPreferences.fontSize))))
                                    .foregroundColor(foregroundColor(entry: entry))
                                    .fontWeight((entry.isButton1 || entry.isButton2 || entry.isButton3) ? .semibold : .regular)
                                    .swipeActions(edge: .leading) {
                                        if userPreferences.activatedButtons[0] {
                                            Button(action: {
                                                toggleButton1(entry: entry)
                                            }) {
                                                Label("", systemImage: userPreferences.image1)
                                            }
                                            .tint(userPreferences.buttonColor1)
                                        }
                                        
                                        if userPreferences.activatedButtons[1] {
                                            Button(action: {
                                                toggleButton2(entry: entry)
                                            }) {
                                                Label("", systemImage: userPreferences.image2)
                                            }
                                            .tint(userPreferences.buttonColor2)
                                        }
                                        if userPreferences.activatedButtons[2] {
                                            Button(action: {
                                                toggleButton3(entry: entry)
                                            }) {
                                                Label("", systemImage: userPreferences.image3)
                                            }
                                            .tint(userPreferences.buttonColor3)
                                        }
                                    }
                            }
                        }

                        .onDelete { indexSet in
                            for index in indexSet {
                                deleteEntry(entry: sortedEntries[index])
                            }
                        }
                    } else {
                        Text("No entries")
                            .foregroundColor(.gray)
                            .italic()
                    }
                }
//                .listStyle(Group``edListStyle())
                .navigationTitle(currentDate())
                .navigationBarItems(trailing:
                                        Button(action: {
                    isShowingEntryCreationView = true
                }, label: {
                    Image(systemName: "plus")
                        .font(.system(size: 16))
                })
                )
                .sheet(isPresented: $isShowingEntryCreationView) {
                    NewEntryView()
                        .environment(\.managedObjectContext, viewContext)
                        .environmentObject(userPreferences)

                }
            }
//            .onAppear(perform: fetchImportantEntries)
//        }
    }
    
    func currentDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: Date())
    }
    
    private func toggleButton1(entry: Entry) {
        print("important")
        entry.isButton1.toggle()
        entry.isButton2 = false
        entry.isButton3 = false
        do {
            try viewContext.save()
            if entry.isButton1 {
                markedEntries.button1_entries.insert(entry)
            } else {
                markedEntries.button1_entries.remove(entry)
            }
        } catch {
            print("Error toggling importance: \(error)")
        }
    }
    
    private func toggleButton2(entry: Entry) {
        print("urgent")
        entry.isButton2.toggle()
        entry.isButton1 = false
        entry.isButton3 = false
        do {
            try viewContext.save()
            if entry.isButton1 {
                markedEntries.button2_entries.insert(entry)
            } else {
                markedEntries.button2_entries.remove(entry)
            }
        } catch {
            print("Error toggling urgency: \(error)")
        }
    }
    
    private func toggleButton3(entry: Entry) {
        entry.isButton3.toggle()
        entry.isButton1 = false
        entry.isButton2 = false
        do {
            try viewContext.save()
            if entry.isButton3 {
                markedEntries.button3_entries.insert(entry)
            } else {
                markedEntries.button3_entries.remove(entry)
            }
        } catch {
            print("Error toggling urgency: \(error)")
        }
    }
    
    private func foregroundColor(entry: Entry) -> Color {
        if entry.isButton1 {
            entry.color = UIColor(userPreferences.buttonColor1)
            return userPreferences.buttonColor1
        }
        else if entry.isButton2 {
            entry.color = UIColor(userPreferences.buttonColor2)
            return userPreferences.buttonColor2
        }
        else if entry.isButton3 {
            entry.color = UIColor(userPreferences.buttonColor3)
            return userPreferences.buttonColor3
        }
        else {
            return .primary
        }
    }
    
    private func fetchMarkedEntries() { //fetches important entries before loading the view
        let fetchRequest_1: NSFetchRequest<Entry> = Entry.fetchRequest()
        fetchRequest_1.predicate = NSPredicate(format: "isButton1 == %@", NSNumber(value: true))
        
        let fetchRequest_2: NSFetchRequest<Entry> = Entry.fetchRequest()
        fetchRequest_2.predicate = NSPredicate(format: "isButton2 == %@", NSNumber(value: true))
        
        let fetchRequest_3: NSFetchRequest<Entry> = Entry.fetchRequest()
        fetchRequest_3.predicate = NSPredicate(format: "isButton3 == %@", NSNumber(value: true))
        
        do {
            let button1_entriesArray = try viewContext.fetch(fetchRequest_1)
            markedEntries.button1_entries = Set(button1_entriesArray)
            
            let button2_entriesArray = try viewContext.fetch(fetchRequest_2)
            markedEntries.button2_entries = Set(button2_entriesArray)
            
            
            let button3_entriesArray = try viewContext.fetch(fetchRequest_3)
            markedEntries.button3_entries = Set(button3_entriesArray)
        } catch {
            print("Error fetching marked entries: \(error)")
        }
    }
    
      private func deleteEntry(entry: Entry) {
          let parentLog = entry.relationship
          parentLog.removeFromRelationship(entry)
          viewContext.delete(entry)
          do {
              try viewContext.save()
          } catch {
              print("Error deleting entry: \(error)")
          }
      }
    @ViewBuilder
    private func validateDate() -> some View {
        if currentDateFilter != formattedDate(Date()) {
            Button("Refresh") {
                currentDateFilter = formattedDate(Date())
            }
        }
    }
}

struct NewEntryView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var userPreferences: UserPreferences

    
    @State private var entryContent = ""

    
    var body: some View {
        VStack {
            Spacer()
                .frame(height: 20) // Adjust the height
            NavigationView { // Wrap in a NavigationView
                VStack {
                    TextEditor(text: $entryContent)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 15).fill(userPreferences.accentColor))
                        .padding()
                    Button("Save") {
                        let newEntry = Entry(context: viewContext)
                        newEntry.content = entryContent
                        newEntry.time = Date()
                        newEntry.isButton1 = false
                        newEntry.isButton2 = false
                        newEntry.isButton3 = false
                        newEntry.color = UIColor(.white) //primary

//                        newEntry.activatedButtons = [true, false, false] //Only button 1 is enabled initially
                        
                        // Fetch the log with the appropriate day
                        let fetchRequest: NSFetchRequest<Log> = Log.fetchRequest()
                        fetchRequest.predicate = NSPredicate(format: "day == %@", formattedDate(newEntry.time))
                        
                        do {
                            let logs = try viewContext.fetch(fetchRequest)
                            print("LOGS: ", logs)
                            if let log = logs.first {
                                log.addToRelationship(newEntry)
                                //                        log.addToEntries(newEntry)
                                newEntry.relationship = log
                                print("log: \(log)")
                                // Adding entry to the dictionary
                            } else {
                                // Create a new log if needed
                                let newLog = Log(context: viewContext)
                                newLog.day = formattedDate(newEntry.time)
                                newLog.addToRelationship(newEntry)
                                //                        newLog.addToEntries(newEntry) // Adding entry to the dictionary
                                print("newLog: \(newLog)")
                                newLog.id = UUID()
                                newEntry.relationship = newLog
                            }
                            try viewContext.save()
                        } catch {
                            print("Error saving new entry: \(error)")
                        }
                        presentationMode.wrappedValue.dismiss()
                    }
                    .padding()
                }
                .navigationBarTitle("New Entry") // Set the title
            }
            Spacer()
                .frame(height: 20) // Adjust the height
        }
    }
}
