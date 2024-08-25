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

    @ObservedObject var reminderManager: ReminderManager

    var body: some View {
        if reminderManager.hasReminderAccess {
            List {
                reminderSections()
                    .listRowBackground(userPreferences.entryBackgroundColor)
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
            .navigationTitle("Set Reminder")
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button("Cancel") {
//                        showingReminderSheet = false
//                    }
//                }
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button("Done") {
//                        saveReminder()
//                        showingReminderSheet = false
//                    }
//                }
//            }
            .font(.system(size: 15))
            .padding()
        } else {
            Text("Reminder Permissions Disabled")
                .foregroundColor(.gray)
        }
    }

    @ViewBuilder
    func reminderSections() -> some View {
        HStack {
            Spacer()
            Button("Done") {
                saveReminder()
                showingReminderSheet = false
            }
        }
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
                ForEach(reminderManager.recurrenceOptions, id: \.self) { option in
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

    func saveReminder() {
        let combinedDateTime = Calendar.current.date(bySettingHour: Calendar.current.component(.hour, from: selectedReminderTime), minute: Calendar.current.component(.minute, from: selectedReminderTime), second: 0, of: selectedReminderDate) ?? Date()

        reminderManager.createOrUpdateReminder(
            reminderId: reminderId,
            title: reminderTitle.isEmpty ? "Reminder" : reminderTitle,
            dueDate: combinedDateTime,
            recurrence: selectedRecurrence,
            notes: reminderNotes
        ) { result in
            switch result {
            case .success(let newReminderId):
                reminderId = newReminderId
                print("Reminder saved with ID: \(newReminderId)")
            case .failure(let error):
                print("Failed to save reminder: \(error)")
            }
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
}
