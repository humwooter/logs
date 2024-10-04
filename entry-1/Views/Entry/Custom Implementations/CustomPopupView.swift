//
//  CustomPopupView.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 8/19/24.
//

import SwiftUI
import EventKit

struct CustomPopupView<Content: View>: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var userPreferences: UserPreferences
    @Environment(\.colorScheme) var colorScheme

    let content: Content
    let title: String
    var height: CGFloat
    var onSave: () -> Void
    
    init(isPresented: Binding<Bool>, height: CGFloat = UIScreen.main.bounds.height * 0.5, title: String = "Popup", onSave: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self._isPresented = isPresented
        self.content = content()
        self.height = height
        self.title = title
        self.onSave = onSave
    }
    
    var body: some View {
        ZStack {
            if isPresented {
                backgroundBlur
                
                VStack(spacing: 0) {
                    header
                    Divider().background(getTextColor().opacity(0.2))
                    contentArea
                }
                .background(popupBackground)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
//                .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
                .frame(maxWidth: UIScreen.main.bounds.width * 0.95, maxHeight: height)
                .padding(.horizontal)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPresented)
    }
    
    private var backgroundBlur: some View {
        var backgroundColor = userPreferences.backgroundColors.first ?? Color.clear
        if isClear(for: UIColor(backgroundColor)) {
            backgroundColor = getDefaultBackgroundColor(colorScheme: colorScheme)
        }
        let best_colorScheme = which_colorScheme(for: UIColor(backgroundColor))
        
        
        return VisualEffectBlur(blurStyle: best_colorScheme == .dark ? .systemUltraThinMaterialLight : .systemUltraThinMaterialDark) // to maximize contrast between foreground and background
            .edgesIgnoringSafeArea(.all)
            .onTapGesture { isPresented = false }
    }
    
    private var header: some View {
        HStack {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(getTextColor())
            Spacer()
            Button(action: {
                onSave()
                isPresented = false
            }) {
                Text("Done")
                    .foregroundStyle(Color(UIColor.fontColor(forBackgroundColor: UIColor(userPreferences.accentColor))))
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(userPreferences.accentColor)
                    .clipShape(Capsule())
            }
        }
        .padding()
    }
    
    private var contentArea: some View {
            content
    }
    
    private var popupBackground: some View {
        var backgroundColor_top = userPreferences.backgroundColors.first ?? Color.clear
        var backgroundColor_bottom = userPreferences.backgroundColors[1]

        if isClear(for: UIColor(userPreferences.backgroundColors.first ?? Color.clear)) {
            backgroundColor_top = getDefaultBackgroundColor(colorScheme: colorScheme)
        }
        if isClear(for: UIColor(backgroundColor_bottom)) {
            backgroundColor_bottom = getDefaultBackgroundColor(colorScheme: colorScheme)
        }
        return LinearGradient(colors: [backgroundColor_top, backgroundColor_bottom],
                       startPoint: .top,
                       endPoint: .bottom)
    }
    
  
    func getTextColor() -> Color {
        calculateTextColor(
            basedOn: userPreferences.backgroundColors.first ?? Color.clear,
            background2: userPreferences.backgroundColors[1],
            entryBackground: userPreferences.entryBackgroundColor,
            colorScheme: colorScheme
        )
    }
}


// Example usage for entry name selection
struct EntryNamePopup: View {
    @Binding var isPresented: Bool
    @Binding var entryName: String
    
    
    @EnvironmentObject var userPreferences: UserPreferences
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            Section {
                TextField("", text: $entryName, prompt: Text("Enter name")                    .foregroundStyle(getIdealTextColor(userPreferences: userPreferences, colorScheme: colorScheme).opacity(0.5)))                .font(.customHeadline)

                    .textFieldStyle(PlainTextFieldStyle())
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(getIdealTextColor(userPreferences: userPreferences, colorScheme: colorScheme))
                    .padding()
            }
        }
        .padding()
        .frame(maxHeight: 100)
    }
}

struct DateEditPopupView: View {
    @Binding var selectedDate: Date
    @EnvironmentObject var userPreferences: UserPreferences
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        List {
            DatePicker("Entry Date", selection: $selectedDate)
                .accentColor(userPreferences.accentColor)
                .listRowBackground(getSectionColor())
                .foregroundStyle(getTextColor())
                .datePickerStyle(.compact)
                .font(.customHeadline)
//                .foregroundStyle(userPreferences.accentColor)
                .padding()
        }
        .scrollContentBackground(.hidden)
       

    }
    
    func getTextColor() -> Color {
        let background1 = userPreferences.backgroundColors.first ?? Color.clear
        let background2 = userPreferences.backgroundColors[1]
        let entryBackground = getSectionColor()
        
        return calculateTextColor(
            basedOn: background1,
            background2: background2,
            entryBackground: entryBackground,
            colorScheme: colorScheme
        )

    }
    
    func getSectionColor() -> Color {
        if isClear(for: UIColor(userPreferences.entryBackgroundColor)) {
            return getDefaultEntryBackgroundColor(colorScheme: colorScheme)
        }
        return userPreferences.entryBackgroundColor
    }
}

struct ReminderPopupView: View {
    @Binding var isPresented: Bool
    @Binding var reminderTitle: String
    @Binding var selectedReminderDate: Date
    @Binding var selectedReminderTime: Date
    @Binding var selectedRecurrence: String
    @Binding var reminderNotes: String

    @Binding var reminderId: String?
    @Binding var showingReminderSheet: Bool
    @Binding var showDeleteReminderAlert: Bool
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var userPreferences: UserPreferences

    @ObservedObject var reminderManager: ReminderManager

    var body: some View {
        if reminderManager.hasReminderAccess {
            List {
                reminderSections()
                    .listRowBackground(getSectionColor())
                    .foregroundStyle(getTextColor())
            }
            .alert("Are you sure you want to delete this reminder?", isPresented: $showDeleteReminderAlert) {
                Button("Delete", role: .destructive) {
                    if let reminderId = reminderId {
                        reminderManager.deleteReminder(reminderId: reminderId) { result in
                            switch result {
                            case .success:
                                print("Reminder deleted successfully.")
                            case .failure(let error):
                                print("Failed to delete reminder: \(error)")
                            }
                        }
                    }
                    showingReminderSheet = false
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This action cannot be undone.")
            }
            .scrollContentBackground(.hidden)
            .font(.customHeadline)
            .padding()
        } else {
            Text("Reminder Permissions Disabled")
                .foregroundColor(.gray)
        }
    }

    @ViewBuilder
    func reminderSections() -> some View {
        Section {
            TextField("Title", text: $reminderTitle, prompt: Text("Enter name")                .foregroundStyle(getTextColor().opacity(0.5)))
                .textFieldStyle(PlainTextFieldStyle())
                .frame(maxWidth: .infinity)
        }
        .foregroundStyle(getTextColor())

        Section {
            DatePicker("Date", selection: $selectedReminderDate, displayedComponents: .date)
            DatePicker("Time", selection: $selectedReminderTime, displayedComponents: .hourAndMinute)

        }
        .accentColor(userPreferences.accentColor)
        .foregroundStyle(getTextColor())

      
                Picker("Recurrence", selection: $reminderManager.selectedRecurrence) {
                    ForEach(reminderManager.recurrenceOptions, id: \.self) { option in
                        Text(option).tag(option)
                            .foregroundStyle(getTextColor())
                    }
                }
                .foregroundStyle(getTextColor())
                .font(.customHeadline)
                .pickerStyle(MenuPickerStyle())
                .accentColor(userPreferences.accentColor)


        if reminderManager.reminderExists(with: reminderId ?? "") {
            Section {
                Button {
                    if let reminderId = self.reminderId, !reminderId.isEmpty {
                        reminderManager.createOrUpdateReminder(reminderId: reminderId, title: reminderTitle, dueDate: selectedReminderDate, recurrence: selectedRecurrence, notes: reminderNotes) { result in
                            switch result {
                            case .success:
                                print("Reminder completed successfully.")
                                self.reminderId = ""
                            case .failure(let error):
                                print("Failed to complete the reminder: \(error)")
                            }
                        }
                        showingReminderSheet = false
                    }
                } label: {
                    Label("Complete", systemImage: "calendar.badge.checkmark")
                        .foregroundColor(.green)
                }
                
                Button {
                    showDeleteReminderAlert = true
                } label: {
                    Label("Delete", systemImage: "trash")
                        .foregroundColor(.red)
                }
            }
        }
    }

    func getSectionColor() -> Color {
        if isClear(for: UIColor(userPreferences.entryBackgroundColor)) {
            return getDefaultEntryBackgroundColor(colorScheme: colorScheme)
        }
        return userPreferences.entryBackgroundColor
    }

    func getTextColor() -> Color {
        let background1 = userPreferences.backgroundColors.first ?? Color.clear
        let background2 = userPreferences.backgroundColors[1]
        let entryBackground = userPreferences.entryBackgroundColor

        return calculateTextColor(
            basedOn: background1,
            background2: background2,
            entryBackground: entryBackground,
            colorScheme: colorScheme
        )
    }
}

import Foundation
import SwiftUI
import CoreData

struct FolderSelectionView: View {
    @Binding var isPresented: Bool
    @Binding var folderId: String?
    @State private var newFolderName: String = ""
    @State private var refreshID = UUID()
    
    @FetchRequest(
        entity: Folder.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Folder.order, ascending: true), NSSortDescriptor(keyPath: \Folder.name, ascending: true)],
        predicate:   NSPredicate(format: "isRemoved != true"),
        animation: .default
    ) var availableFolders: FetchedResults<Folder>
    
    @EnvironmentObject var userPreferences: UserPreferences
    @EnvironmentObject var coreDataManager: CoreDataManager
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            // New Folder Input Section
            HStack {
                TextField("Create new folder", text: $newFolderName, prompt: Text("Enter folder name")
                            .foregroundStyle(getTextColor().opacity(0.5)))
                    .textFieldStyle(.plain)
                    .padding()
                    .font(.buttonSize)
                    .foregroundStyle(getTextColor())
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(userPreferences.entryBackgroundColor)
                            .stroke(getTextColor().opacity(0.2), lineWidth: 1)
                    )

                Button(action: addNewFolder) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(userPreferences.accentColor)
                }
                .padding(.trailing)
                .disabled(newFolderName.isEmpty)
            }
            .padding(.horizontal)
            .padding(.vertical)

            // Folder Selection List
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                    ForEach(availableFolders, id: \.id) { folder in
                        folderButton(folder: folder, isSelected: folder.id.uuidString == folderId) {
                            toggleFolderSelection(folder)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .cornerRadius(20)
        .id(refreshID) // Force the view to refresh when refreshID changes
    }
    
    func getTextColor() -> Color {
        let background1 = userPreferences.backgroundColors.first ?? Color.clear
        let background2 = userPreferences.backgroundColors.count > 1 ? userPreferences.backgroundColors[1] : background1
        let entryBackground = getSectionColor()
        
        return calculateTextColor(
            basedOn: background1,
            background2: background2,
            entryBackground: entryBackground,
            colorScheme: colorScheme
        )
    }
    
    func getSectionColor() -> Color {
        if isClear(for: UIColor(userPreferences.entryBackgroundColor)) {
            return getDefaultEntryBackgroundColor(colorScheme: colorScheme)
        }
        return userPreferences.entryBackgroundColor
    }
  
    func getSelectedTextColor() -> Color {
        return Color(UIColor.fontColor(forBackgroundColor: UIColor(userPreferences.accentColor)))
    }
    
    // Add new folder to Core Data
    private func addNewFolder() {
        guard !newFolderName.isEmpty else { return }
        
        // Check if the folder already exists
        if availableFolders.contains(where: { $0.name == newFolderName }) {
            print("Folder already exists: \(newFolderName)")
            return
        }
        
        // Create and save the new folder
        let newFolder = Folder(context: coreDataManager.viewContext)
        newFolder.id = UUID()
        newFolder.name = newFolderName
        newFolder.order = Int16(availableFolders.count)
        newFolder.entryCount = 0
        newFolder.dateCreated = Date()
        newFolder.isRemoved = false
        
        do {
            try coreDataManager.viewContext.save()
            newFolderName = ""
            refreshID = UUID() // Change the refreshID to force the view to reload
        } catch {
            print("Error saving new folder: \(error)")
        }
    }
    
    // Toggle folder selection
    private func toggleFolderSelection(_ folder: Folder) {
        if folderId == folder.id.uuidString {
            // If the selected folder is clicked again, unselect it
            folderId = nil
        } else {
            // Otherwise, select the new folder
            folderId = folder.id.uuidString
        }
        
//        do {
//            try coreDataManager.viewContext.save()
//        } catch {
//            print("Error updating folder selection: \(error)")
//        }
//        
        // Dismiss the selection view (optional based on your logic)
        // isPresented = false
    }
    
    @ViewBuilder
    func folderButton(folder: Folder, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Label(folder.name ?? "", systemImage: "folder.fill")
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                }
            }
            .padding()
            .background(
                isSelected ?
                userPreferences.accentColor :
                    getSectionColor()
            )
            .foregroundColor(isSelected ? getSelectedTextColor() : getTextColor())
            .cornerRadius(10)
        }
    }
}
