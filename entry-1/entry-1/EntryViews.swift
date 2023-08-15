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

class ImportantEntries: ObservableObject {
    @Published var entries: Set<Entry> = []
    
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

    @ObservedObject var importantEntries = ImportantEntries()

    
    @EnvironmentObject var userPreferences: UserPreferences

    var body: some View {
            NavigationView {
                List {
                    validateDate()
                    if let firstLog = logs.first, firstLog.relationship.count > 0 {
                        let sortedEntries = Array(firstLog.relationship as! Set<Entry>).sorted { $0.time > $1.time }
                        ForEach(sortedEntries, id: \.self) { entry in
                            Section(header: Text(entry.formattedTime())
                            ) {
                                Text(entry.content)
                                    .font(.custom(String(userPreferences.fontName), size: CGFloat(Float(userPreferences.fontSize))))
                                    .foregroundColor(entry.isImportant ? .yellow : .primary)
                                    .fontWeight(entry.isImportant ? .semibold : .regular)

                                    .swipeActions(edge: .leading) {
                                        Button(action: {
                                            toggleImportance(entry: entry)
                                        }) {
                                            Label("Important", systemImage: "star.fill")
                                        }
                                        .tint(.yellow)
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
                .navigationTitle(currentDate())
                .navigationBarItems(trailing:
                                        Button(action: {
                    isShowingEntryCreationView = true
                }, label: {
                    Image(systemName: "plus")
                })
                )
                .sheet(isPresented: $isShowingEntryCreationView) {
                    NewEntryView().environment(\.managedObjectContext, viewContext)
                }
            }
            .onAppear(perform: fetchImportantEntries)
//        }
        
    }
    func currentDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: Date())
    }
    
    private func toggleImportance(entry: Entry) {
        entry.isImportant.toggle()
        do {
            try viewContext.save()
            if entry.isImportant {
                importantEntries.entries.insert(entry)
            } else {
                importantEntries.entries.remove(entry)
            }
        } catch {
            print("Error toggling importance: \(error)")
        }
    }
    private func fetchImportantEntries() { //fetches important entries before loading the view
        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isImportant == %@", NSNumber(value: true))
        do {
            let importantEntriesArray = try viewContext.fetch(fetchRequest)
            importantEntries.entries = Set(importantEntriesArray)
        } catch {
            print("Error fetching important entries: \(error)")
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
    
    @State private var entryContent = ""

    
    var body: some View {
        VStack {
            Spacer()
                .frame(height: 20) // Adjust the height
            NavigationView { // Wrap in a NavigationView
                VStack {
                    TextEditor(text: $entryContent)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 7).fill(Color.gray.opacity(0.15)))
                        .padding()
//                        .background(.indigo)
                    Button("Save") {
                        let newEntry = Entry(context: viewContext)
                        newEntry.content = entryContent
                        newEntry.time = Date()
                        
                        
                        
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
                .navigationBarTitle("New Entry", displayMode: .inline) // Set the title
            }
            Spacer()
                .frame(height: 20) // Adjust the height
        }
    }
}
