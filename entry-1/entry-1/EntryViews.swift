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
    @Published var button_entries: [Set<Entry>] = [[], [], [], [], []]

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
    
    @ObservedObject var markedEntries = MarkedEntries()
    @EnvironmentObject var userPreferences: UserPreferences
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedEntry: Entry?
    let generator = UIImpactFeedbackGenerator(style: .medium)

    var body: some View {
            NavigationView {
                List {
                    validateDate()
                    if let firstLog = logs.first, firstLog.relationship.count > 0 {
                        let sortedEntries = Array(firstLog.relationship as! Set<Entry>).sorted { $0.time > $1.time }
                        ForEach(sortedEntries, id: \.self) { entry in
                            Section(header: Text(entry.formattedTime()).font(.system(size: UIFont.systemFontSize))) {
                                Text(entry.content)
                                    .foregroundColor(foregroundColor(entry: entry, background: entry.color)) //to determinw whether black or white
                                    .fontWeight(entry.buttons.filter{$0}.count > 0 ? .semibold : .regular)
                                
                                    .swipeActions(edge: .leading) {
                                        ForEach(0..<userPreferences.activatedButtons.count, id: \.self) { index in
                                            if userPreferences.activatedButtons[index] {
                                                Button(action: {
                                                    activateButton(entry: entry, index: index)
                                                }) {
                                                    Label("", systemImage: userPreferences.selectedImages[index])
                                                }
                                                .tint(userPreferences.selectedColors[index])
                                            }
                                        }
                                    }
                                    .sheet(item: $selectedEntry) { entry in
                                        
                                    }
                                
                            }
                            .listRowBackground(backgroundColor(entry: entry))
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
    
    
    private func activateButton(entry: Entry, index: Int) {
        print()
        print("INDEX: \(index)")
        print("in activate button")
        print("entry.buttons: \(entry.buttons)")
        print("userPreferences.activatedButtons: \(userPreferences.activatedButtons)")
        if (index+1 > entry.buttons.count) {
            entry.buttons = [false, false, false, false, false]
            entry.buttons[index] = true
        }
        else {
            let val : Bool = !entry.buttons[index] //this is what it means to toggle
            entry.buttons = [false, false, false, false, false]
            entry.buttons[index] = val
        }
        entry.color = UIColor(userPreferences.selectedColors[index])
        entry.image = userPreferences.selectedImages[index]

        do {
            try viewContext.save()
            if entry.buttons[index] == true {
                markedEntries.button_entries[index].insert(entry)
            } else {
                markedEntries.button_entries[index].remove(entry)
            }
        } catch {
            print("Error toggling button \(index+1): \(error)")
        }
    }
    
  
    private func foregroundColor(entry: Entry, background: UIColor) -> Color {
        print("entry.color: \(entry.color)")
        print()
        let color = colorScheme == .dark ? Color.white : Color.black
        if (entry.buttons.filter{$0}.count == 0) {
            return color
        }
        
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        background.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        let brightness = (red * 299 + green * 587 + blue * 114) / 1000

        return brightness > 0.5 ? Color.black : Color.white
    }
    
    private func backgroundColor(entry: Entry) -> Color {
        let opacity_val = colorScheme == .dark ? 0.90 : 0.75

        print("entry.buttons: \(entry.buttons)")
        print("userPreferences.activatedButtons: \(userPreferences.activatedButtons)")
        print("userPreferences.selectedColors: \(userPreferences.selectedColors)")

        if entry.buttons.count < 5 {
            print("true")
            entry.buttons = [true, false, false, false, false]
        }

        for index in 0..<5 {
            if entry.buttons[index] {
                return Color(entry.color).opacity(opacity_val)
            }
        }

        let color = colorScheme == .dark ? UIColor.secondarySystemBackground : UIColor.tertiarySystemBackground
        entry.color = colorScheme == .dark ? UIColor(Color.white) : UIColor(Color.black)
        return Color(color)
    }


    private func fetchMarkedEntries() { //fetches important entries before loading the view
        let fetchRequest_1: NSFetchRequest<Entry> = Entry.fetchRequest()
        fetchRequest_1.predicate = NSPredicate(format: "buttons[0] == %@", NSNumber(value: true))
        
        let fetchRequest_2: NSFetchRequest<Entry> = Entry.fetchRequest()
        fetchRequest_2.predicate = NSPredicate(format: "buttons[1] == %@", NSNumber(value: true))
        
        let fetchRequest_3: NSFetchRequest<Entry> = Entry.fetchRequest()
        fetchRequest_3.predicate = NSPredicate(format: "buttons[2] == %@", NSNumber(value: true))
        
        let fetchRequest_4: NSFetchRequest<Entry> = Entry.fetchRequest()
        fetchRequest_4.predicate = NSPredicate(format: "buttons[3] == %@", NSNumber(value: true))
        
        let fetchRequest_5: NSFetchRequest<Entry> = Entry.fetchRequest()
        fetchRequest_5.predicate = NSPredicate(format: "buttons[4] == %@", NSNumber(value: true))
        
        
        
        
        do {
            let button1_entriesArray = try viewContext.fetch(fetchRequest_1)
            markedEntries.button_entries[0] = Set(button1_entriesArray)
            
            let button2_entriesArray = try viewContext.fetch(fetchRequest_2)
            markedEntries.button_entries[1] = Set(button2_entriesArray)
            
            
            let button3_entriesArray = try viewContext.fetch(fetchRequest_3)
            markedEntries.button_entries[2] = Set(button3_entriesArray)
            
            let button4_entriesArray = try viewContext.fetch(fetchRequest_4)
            markedEntries.button_entries[3] = Set(button4_entriesArray)
            
            
            let button5_entriesArray = try viewContext.fetch(fetchRequest_5)
            markedEntries.button_entries[4] = Set(button5_entriesArray)
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
    @Environment(\.colorScheme) var colorScheme


    
    @State private var entryContent = ""

    
    var body: some View {
        VStack {
            Spacer()
                .frame(height: 20) // Adjust the height
            NavigationView { // Wrap in a NavigationView
                VStack {
                    TextEditor(text: $entryContent)
                        .padding()
//                        .background(RoundedRectangle(cornerRadius: 15).fill(userPreferences.accentColor))
                        .padding()
                    Button("Done") {
                        let color = colorScheme == .dark ? Color.white : Color.black
                        let newEntry = Entry(context: viewContext)
                        newEntry.content = entryContent
                        newEntry.time = Date()
                        newEntry.buttons = [false, false, false, false, false]
                        newEntry.color = UIColor(color)
                        newEntry.image = "star.fill"
                        
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
                    .font(.system(size: 16)) // Set the font size to 24 or any value you prefer
                    .padding()
                }
                .navigationBarTitle("New Entry") // Set the title
            }
            Spacer()
                .frame(height: 20) // Adjust the height
        }
    }
}



struct EditEntryView: View {
    @Binding var content: String
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            TextField("Edit content", text: $content)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Button("Save") {
                // Your logic to save the changes goes here
                presentationMode.wrappedValue.dismiss() // Close the view
            }
            .padding()
        }
        .navigationTitle("Edit Entry")
    }
}


struct GlassButtonStyle: ButtonStyle {
    var accentColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white) // White text color
            .padding() // Padding around the text
            .background(
                RoundedRectangle(cornerRadius: 15) // Rounded rectangle shape
                    .fill(accentColor) // Accent color as background
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(
                                LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.3), Color.clear]), startPoint: .top, endPoint: .bottom) // Glass-like gradient
                            )
                    )
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 10) // Soft shadow for 3D effect
            )
            .opacity(configuration.isPressed ? 0.7 : 1) // Changes opacity when pressed
            .scaleEffect(configuration.isPressed ? 0.95 : 1) // Slightly reduces the size when pressed
    }
}
