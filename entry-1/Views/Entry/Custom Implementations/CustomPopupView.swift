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
    var height: CGFloat
    
    init(isPresented: Binding<Bool>, height: CGFloat = UIScreen.main.bounds.height * 0.5, @ViewBuilder content: () -> Content) {
        self._isPresented = isPresented
        self.content = content()
        self.height = height
    }
    
    var body: some View {
        ZStack {
            if isPresented {
                // Semi-transparent background
                VisualEffectBlur(blurStyle: .systemUltraThinMaterial)
                                  .edgesIgnoringSafeArea(.all)
                                  .onTapGesture {
                                      isPresented = false
                                  }
                                
                        
                
                // Popup content
                VStack {
                    content
                        .padding()
                        .background(LinearGradient(colors: [userPreferences.backgroundColors.first ?? Color.clear, userPreferences.backgroundColors[1]], startPoint: .top, endPoint: .bottom))
                        .cornerRadius(30)
                        .shadow(radius: 10)
                        .frame(maxWidth: UIScreen.main.bounds.width * 0.95)  // Adjust width
                        .frame(maxHeight: height)  // Control the height of the popup
                        .foregroundStyle(getTextColor())
                }
                .padding()
                .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isPresented)
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


struct TagSelectionPopup: View {
    @Binding var isPresented: Bool
    @Binding var selectedTags: [String]
    let availableTags: [String]
    
    @EnvironmentObject var userPreferences: UserPreferences
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            Text("Select Tags").padding()
                .font(.headline)
            
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))]) {
                    ForEach(availableTags, id: \.self) { tag in
                        TagButton(tag: tag, isSelected: selectedTags.contains(tag)) {
                            if selectedTags.contains(tag) {
                                selectedTags.removeAll { $0 == tag }
                            } else {
                                selectedTags.append(tag)
                            }
                        }
                    }
                }
            }
            
            Button("Done") {
                isPresented = false
            }
            .padding()
        }
        .frame(maxHeight: 300)
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
            Text("Choose Entry Name")
                .font(.headline)
            
            TextField("Entry Name", text: $entryName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("Done") {
                isPresented = false
            }
            .padding()
        }
    }
}

struct TagButton: View {
    let tag: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(tag).font(.footnote)
                .padding(.horizontal)
                .padding(.vertical)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(15)
        }
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
    let recurrenceOptions: [String] = ["None", "Daily", "Weekly", "Monthly"]
    let hasReminderAccess: Bool



    var body: some View {
                if hasReminderAccess {
                    List {
                        reminderSections()
                            .listRowBackground(userPreferences.entryBackgroundColor)

                        .foregroundStyle(getTextColor())
                    }

                    .alert("Are you sure you want to delete this reminder?", isPresented: $showDeleteReminderAlert) {
                        Button("Delete", role: .destructive) {
                            deleteReminder(reminderId: reminderId)
                            showingReminderSheet = false
                        }
                        Button("Cancel", role: .cancel) {}
                    } message: {
                        Text("This action cannot be undone.")
                    }
                    .scrollContentBackground(.hidden)
                    .font(.system(size: 15))
                    .navigationTitle("Set Reminder")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Cancel") {
                                showingReminderSheet = false
                            }
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                createOrUpdateReminder()
                            }
                        }
                    }
                    .font(.system(size: 15))
                    .padding()
                } else {
                    Text("Reminder Permissions Disabled")
                        .foregroundColor(.gray)
                }
                    
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
    
    func editAndSaveReminder(reminderId: String?, title: String, dueDate: Date, recurrenceOption: String, completion: @escaping (Bool, String?) -> Void) {
        let eventStore = EKEventStore()

        eventStore.requestFullAccessToReminders { granted, error in
            guard granted, error == nil else {
                DispatchQueue.main.async {
                    completion(false, nil)
                }
                return
            }

            var reminder: EKReminder
            if let reminderId = reminderId, let existingReminder = eventStore.calendarItem(withIdentifier: reminderId) as? EKReminder {
                reminder = existingReminder
            } else {
                reminder = EKReminder(eventStore: eventStore)
                reminder.calendar = eventStore.defaultCalendarForNewReminders()
            }

            reminder.title = title
            reminder.dueDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dueDate)
            if let recurrenceRule = createRecurrenceRule(fromOption: recurrenceOption) {
                reminder.recurrenceRules = [recurrenceRule] // Replace existing rules with the new one
            }

            do {
                try eventStore.save(reminder, commit: true)
                DispatchQueue.main.async {
                    completion(true, reminder.calendarItemIdentifier)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(false, nil)
                }
            }
        }
    }

    
    
    
    func createAndSaveReminder(title: String, dueDate: Date, recurrenceOption: String, completion: @escaping (Bool, String?) -> Void) {
        // Initialize the store.
        let eventStore = EKEventStore()

        // Request access to reminders.
        requestReminderAccess { granted in
            if granted {
                let reminder = EKReminder(eventStore: eventStore)
                reminder.calendar = eventStore.defaultCalendarForNewReminders()
                reminder.title = title
                reminder.dueDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dueDate)
                reminder.notes = reminderNotes
                // Set recurrence rule if applicable
                if let recurrenceRule = createRecurrenceRule(fromOption: recurrenceOption) {
                    reminder.addRecurrenceRule(recurrenceRule)
                }

                // Try to save the reminder
                do {
                    try eventStore.save(reminder, commit: true)
                    completion(true, reminder.calendarItemIdentifier) // Return success and the reminder identifier
                } catch {
                    completion(false, nil) // Return failure
                }
            } else {
                // Handle the case where permission is not granted
                completion(false, nil)
            }
        }
    }
    
    func createOrUpdateReminder() {
        let eventStore = EKEventStore()
        let combinedDateTime = Calendar.current.date(bySettingHour: Calendar.current.component(.hour, from: selectedReminderTime), minute: Calendar.current.component(.minute, from: selectedReminderTime), second: 0, of: selectedReminderDate) ?? Date()

        eventStore.requestAccess(to: .reminder) { granted, error in
            guard granted, error == nil else {
                print("Access to reminders denied or failed.")
                showingReminderSheet = false
                return
            }

            if reminderExists(with: reminderId ?? "", in: eventStore) {
                // Existing reminder found, update it
                editAndSaveReminder(reminderId: reminderId, title: reminderTitle.isEmpty ? "Reminder" : reminderTitle, dueDate: combinedDateTime, recurrenceOption: selectedRecurrence) { success, updatedReminderId in
                    if success, let updatedReminderId = updatedReminderId {
                        reminderId = updatedReminderId
                        print("Reminder updated with identifier: \(updatedReminderId)")
                    } else {
                        print("Failed to update the reminder")
                    }
                    showingReminderSheet = false
                }
            } else {
                // No existing reminder, create a new one
                createAndSaveReminder(title: reminderTitle.isEmpty ? "Reminder" : reminderTitle, dueDate: combinedDateTime, recurrenceOption: selectedRecurrence) { success, newReminderId in
                    if success, let newReminderId = newReminderId {
                        reminderId = newReminderId
                        print("New reminder created with identifier: \(newReminderId)")
                    } else {
                        print("Failed to create a new reminder")
                    }
                    showingReminderSheet = false
                }
            }
        }
    }
    
    func reminderExists(with identifier: String, in eventStore: EKEventStore) -> Bool {
        if let _ = eventStore.calendarItem(withIdentifier: identifier) as? EKReminder {
            return true
        } else {
            return false
        }
    }
    
    
    @ViewBuilder
    func reminderSections() -> some View {
        Section {
            TextField("Title", text: $reminderTitle)
                .textFieldStyle(PlainTextFieldStyle())
                .frame(maxWidth: .infinity)
        }
    
    Section {
        TextField("Notes", text: $reminderNotes)
            .textFieldStyle(PlainTextFieldStyle())
            .frame(maxWidth: .infinity)
    }
        
        Section {
            DatePicker("Date", selection: $selectedReminderDate, displayedComponents: .date)
            DatePicker("Time", selection: $selectedReminderTime, displayedComponents: .hourAndMinute)
        }
        .accentColor(userPreferences.accentColor)
        
        NavigationLink {
            Picker("Recurrence", selection: $selectedRecurrence) {
                ForEach(recurrenceOptions, id: \.self) { option in
                    Text(option).tag(option)
                }
            }
            .font(.system(size: 15))
            .pickerStyle(.inline)
            .accentColor(userPreferences.accentColor)
        } label: {
            Label("Repeat", systemImage: "repeat")
        }
        .font(.system(size: 15))
        .accentColor(userPreferences.accentColor)
        
        Section {
            Button {
                if let reminderId = self.reminderId, !reminderId.isEmpty {
                    completeReminder(reminderId: reminderId) { success, error in
                        if success {
                            print("Reminder completed successfully.")
                            self.reminderId = ""
                        } else {
                            print("Failed to complete the reminder: \(String(describing: error))")
                        }
                    }
                    print("Reminder completed")
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
