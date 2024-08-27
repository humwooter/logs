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

struct TagSelectionPopup: View {
    @Binding var isPresented: Bool
    @Binding var entryId: UUID
    @Binding var selectedTags: [String] // This stores the selected tag names
    @State private var newTagName: String = ""
    @State private var refreshID = UUID()
    @Binding var currentTags: [Tag: Bool]

    @FetchRequest(
        entity: Tag.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Tag.numEntries, ascending: false), NSSortDescriptor(keyPath: \Tag.name, ascending: true)],
        animation: .default
    ) var availableTags: FetchedResults<Tag>
    
    @EnvironmentObject var userPreferences: UserPreferences
    @EnvironmentObject var coreDataManager: CoreDataManager
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            // New Tag Input Section
            HStack {
                TextField("Create new tag", text: $newTagName, prompt: Text("Enter tag name")                .foregroundStyle(getTextColor().opacity(0.5))).textFieldStyle(.plain).padding()
                    .font(.buttonSize)
                    .foregroundStyle(getTextColor())
                    .background(
                        RoundedRectangle(cornerRadius: 15).fill(userPreferences.entryBackgroundColor)
                            .stroke(getTextColor().opacity(0.2), lineWidth: 1)
                    )

                Button(action: addNewTag) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(userPreferences.accentColor)
                }
                .padding(.trailing)
                .disabled(newTagName.isEmpty)
            }
            .padding(.horizontal)
            .padding(.vertical)

            // Tag Selection Grid
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]) {
                    ForEach(Array(currentTags.keys), id: \.id) { tag in
                        TagButton(
                            tag: tag,
                            isSelected: currentTags[tag] ?? false
                        ) {
                            toggleTagSelection(tag)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .cornerRadius(20)
        .id(refreshID) // Force the view to refresh when refreshID changes
        .onAppear {
//            deleteAllTags()
            initializeCurrentTags()
        }
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
    
    // Initialize currentTags based on availableTags and selectedTags
    private func initializeCurrentTags() {
        currentTags = [:]
        for tag in availableTags {
            currentTags[tag] = selectedTags.contains(tag.name ?? "")
        }
    }
    
    // Toggle tag selection
    private func toggleTagSelection(_ tag: Tag) {
        if let isSelected = currentTags[tag] {
            currentTags[tag] = !isSelected
            
            if currentTags[tag] == false {
                // Remove the tag from selectedTags if it is no longer selected
                selectedTags.removeAll { $0 == tag.name }
                tag.numEntries -= 1
            } else {
                // Optionally, add the tag to selectedTags if it is selected
                if let tagName = tag.name {
                    selectedTags.append(tagName)
                    tag.numEntries += 1
                }
            }
        }
    }

    
    func formatToTagReadableString(_ input: String) -> String {
        return input
            .lowercased()             // Convert to lowercase
            .replacingOccurrences(of: " ", with: "-") // Replace spaces with dashes
    }


    // Add new tag to Core Data
    private func addNewTag() {
        guard !newTagName.isEmpty else { return }
        
        // Format the new tag name
        let formattedTagName = formatToTagReadableString(newTagName)
        
        // Check if the tag already exists
        if currentTags.keys.contains(where: { $0.name == formattedTagName }) {
            print("Tag already exists: \(formattedTagName)")
            return // Exit the function if the tag already exists
        }
        
        // Create and save the new tag
        let newTag = Tag(context: coreDataManager.viewContext)
        newTag.name = formattedTagName
        newTag.numEntries = 0
        newTag.id = UUID()
        newTag.entryIds.append(entryId.uuidString)
        
        do {
            try coreDataManager.viewContext.save()
            newTagName = ""
            refreshID = UUID() // Change the refreshID to force the view to reload

            // Update currentTags with the new tag
            currentTags[newTag] = true
            selectedTags.append(formattedTagName)
            
            print("CURRENT TAGS: \(currentTags)")
        } catch {
            print("Error saving new tag: \(error)")
        }
    }

}

struct TagButton: View {
    let tag: Tag
    let isSelected: Bool
    let action: () -> Void
    
    @EnvironmentObject var userPreferences: UserPreferences
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(tag.name ?? "")
                    .font(.caption)
                    .padding()
                    .background(
                        isSelected ?
                            LinearGradient(gradient: Gradient(colors: [userPreferences.accentColor.opacity(0.8), userPreferences.accentColor]), startPoint: .topLeading, endPoint: .bottomTrailing) :
                            LinearGradient(gradient: Gradient(colors: [userPreferences.entryBackgroundColor.opacity(0.8), userPreferences.entryBackgroundColor]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .foregroundColor(isSelected ? .white : .primary)
                    .cornerRadius(20)
                
//                if isSelected {
//                    Image(systemName: "checkmark.circle.fill")
//                        .font(.footnote)
//                        .foregroundColor(.white)
//                        .padding(.trailing, 5)
//                }
            }
        }
    }
    
    func getSectionColor() -> Color {
        if isSelected {
            return userPreferences.accentColor
        }
        if isClear(for: UIColor(userPreferences.entryBackgroundColor)) {
            return getDefaultEntryBackgroundColor(colorScheme: colorScheme)
        }
        return userPreferences.entryBackgroundColor
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
    
}


//struct TagSelectionPopup: View {
//    @Binding var isPresented: Bool
//    @Binding var selectedTags: [String]
//    @State private var newTagName: String = ""
//
//    @FetchRequest(
//        entity: Tag.entity(),
//        sortDescriptors: [NSSortDescriptor(keyPath: \Tag.numEntries, ascending: false), NSSortDescriptor(keyPath: \Tag.name, ascending: true)]
//    ) var availableTags: FetchedResults<Tag>
//    
//    @EnvironmentObject var userPreferences: UserPreferences
//    @EnvironmentObject var coreDataManager: CoreDataManager
//    @Environment(\.colorScheme) var colorScheme
//    
//    var body: some View {
//        VStack {
//            // New Tag Input Section
//            HStack {
//                TextField("Create new tag", text: $newTagName)
//                    .font(.buttonSize)
//                    .padding(.horizontal)
//                    .padding(.vertical, 8)
//                    .foregroundStyle(getTextColor())
//                    .background(
//                        RoundedRectangle(cornerRadius: 10)
//                            .stroke(getTextColor().opacity(0.5), lineWidth: 1)
//                    )
//
//                
//                Button(action: addNewTag) {
//                    Image(systemName: "plus.circle.fill")
//                        .font(.title2)
//                        .foregroundColor(userPreferences.accentColor)
//                }
//                .padding(.trailing)
//                .disabled(newTagName.isEmpty)
//            }
//            .padding(.vertical)
//
//            // Tag Selection Grid
//            ScrollView {
//                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))]) {
//                    ForEach(availableTags, id: \.id) { tag in
//                        TagButton(tag: tag, isSelected: selectedTags.contains(tag.name ?? "unnamed tag")) {
//                            toggleTagSelection(tag.name ?? "unnamed tag")
//                        }
//                    }
//                }
//                .padding()
//            }
//        }
//        .frame(maxHeight: 400)
//        .background(getSectionColor())
//        .cornerRadius(20)
//        .shadow(radius: 10)
//        .padding()
//    }
//    
//    func getTextColor() -> Color {
//        let background1 = userPreferences.backgroundColors.first ?? Color.clear
//        let background2 = userPreferences.backgroundColors[1]
//        let entryBackground = getSectionColor()
//        
//        return calculateTextColor(
//            basedOn: background1,
//            background2: background2,
//            entryBackground: entryBackground,
//            colorScheme: colorScheme
//        )
//
//    }
//    
//    func getSectionColor() -> Color {
//        if isClear(for: UIColor(userPreferences.entryBackgroundColor)) {
//            return getDefaultEntryBackgroundColor(colorScheme: colorScheme)
//        }
//        return userPreferences.entryBackgroundColor
//    }
//    
//    // Toggle tag selection
//    private func toggleTagSelection(_ tagName: String) {
//        if selectedTags.contains(tagName) {
//            selectedTags.removeAll { $0 == tagName }
//        } else {
//            selectedTags.append(tagName)
//        }
//    }
//
//    // Add new tag to Core Data
//    private func addNewTag() {
//        guard !newTagName.isEmpty else { return }
//        
//        let newTag = Tag(context: coreDataManager.viewContext)
//        newTag.name = newTagName
//        newTag.numEntries = 0
//        
//        do {
//            try coreDataManager.viewContext.save()
//            selectedTags.append(newTag.name!)
//            newTagName = ""
//        } catch {
//            print("Error saving new tag: \(error)")
//        }
//    }
//}
//
//struct TagButton: View {
//    let tag: Tag
//    let isSelected: Bool
//    let action: () -> Void
//    
//    @EnvironmentObject var userPreferences: UserPreferences
//    @Environment(\.colorScheme) var colorScheme
//    
//    var body: some View {
//        let selectedColor = userPreferences.accentColor
//        let unselectedColor = userPreferences.entryBackgroundColor
//        
//        Button(action: action) {
//            HStack {
//                Text(tag.name ?? "")
//                    .font(.buttonSize)
//                    .padding(.horizontal)
//                    .padding(.vertical, 5)
//                    .background(
//                        isSelected ?
//                            LinearGradient(gradient: Gradient(colors: [selectedColor.opacity(0.8), selectedColor]), startPoint: .topLeading, endPoint: .bottomTrailing) :
//                            LinearGradient(gradient: Gradient(colors: [unselectedColor.opacity(0.8), unselectedColor]), startPoint: .topLeading, endPoint: .bottomTrailing)
//                    )
//                    .foregroundColor(isSelected ? .white : .primary)
//                    .cornerRadius(20)
////                    .shadow(color: isSelected ? selectedColor.opacity(0.4) : Color.gray.opacity(0.2), radius: 5, x: 0, y: 3)
//                
////                if isSelected {
////                    Image(systemName: "checkmark.circle.fill")
////                        .font(.footnote)
////                        .foregroundColor(.white)
////                        .padding(.trailing, 5)
////                }
//            }
//        }
//    }
//}


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
            .font(.system(size: 15))
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
                .font(.system(size: 15))
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
