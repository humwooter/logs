//
//  ReplyEntryView.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 5/4/24.
//

import Foundation

import Foundation
import SwiftUI
import CoreData
import Speech
import AVFoundation
import Photos
import CoreHaptics
import PhotosUI
import FLAnimatedImage
import UniformTypeIdentifiers
import PDFKit
import EventKit


struct ReplyEntryView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var userPreferences: UserPreferences
    @EnvironmentObject var datesModel: DatesModel
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var coreDataManager: CoreDataManager

    
    
    
    @State private var speechRecognizer = SFSpeechRecognizer()
    @State private var recognitionTask: SFSpeechRecognitionTask?
    @State private var audioEngine = AVAudioEngine()
    @State private var isListening = false
    @State private var isImagePickerPresented = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @FocusState private var focusField: Bool
    
    
    @State private var selectedItem : PhotosPickerItem?
    @State private var selectedImage : UIImage?
    @State private var selectedData: Data? //used for gifs
    @State private var selectedPDFLink: URL? //used for gifs

    @State private var isCameraPresented = false
    @State private var filename = ""
    @State private var imageData : Data?
    @State private var imageIsAnimated = false
    @State private var isHidden = false
    @State private var isDocumentPickerPresented = false
    
    
    
    @State private var entryContent = ""
    @State private var imageHeight: CGFloat = 0
    @State private var keyboardHeight: CGFloat = 0
    @State private var isFullScreen = false
    @State private var isTextButtonBarVisible: Bool = false
    @State private var cursorPosition: NSRange? = nil
    
    @State private var selectedDate : Date = Date()
    @State private var selectedTime = Date()

    @State private var selectedReminderDate : Date = Date()
    @State private var selectedReminderTime : Date = Date()


    @State private var showingDatePicker = false // To control the visibility of the date picker
    @ObservedObject var textEditorViewModel = TextEditorViewModel()
    
    
    @State private var showingReminderSheet = false
    @State private var selectedRecurrence = "None"
    @State private var reminderTitle: String = ""
    @State private var reminderId: String?
    @State var replyEntryId: String //the id of the entry that is being replied to with this current new one
    @State private var hasReminderAccess = false
    
    @State private var showDeleteReminderAlert = false
    // Define your recurrence options
    let recurrenceOptions = ["None", "Daily", "Weekly", "Weekends", "Biweekly", "Monthly"]

    @State var isEditing = false //for being able to use NotEditingView for repliedEntryView
    
    var body: some View {
        NavigationStack {
            VStack {

                    VStack {
                        
                        
                        HStack() {
                            Spacer()
                            if let reminderId = self.reminderId, !reminderId.isEmpty {
                                Image(systemName: "bell.fill").foregroundStyle(userPreferences.reminderColor)
                                    .font(.system(size: 20))
                                    .padding(.horizontal)
                            }
                        }
//                            textFieldView()
                        finalRepliedView()
                        Spacer()
                    }
                    .onTapGesture {
                        focusField = true
                    }

                VStack {
                    HStack {
                        Button(action: {
                            withAnimation(.easeOut(duration: 0.5)) {
                                isTextButtonBarVisible.toggle()
                            }
                        }) {
                            HStack {
                                Image(systemName: isTextButtonBarVisible ? "chevron.left" : "text.justify.left")
                                    .font(.system(size: 20))
                                    .foregroundColor(userPreferences.accentColor)
                                    .padding([.leading, .bottom])
                            }
                        }
                        
                        if isTextButtonBarVisible {
                            textFormattingButtonBar()
                        }
                        Spacer()
                    }
                    buttonBar()
                }.padding(.bottom)
              
           
            }

            .background {
                    ZStack {
                        Color(UIColor.systemGroupedBackground)
                        LinearGradient(colors: [userPreferences.backgroundColors[0], userPreferences.backgroundColors.count > 1 ? userPreferences.backgroundColors[1] : userPreferences.backgroundColors[0]], startPoint: .top, endPoint: .bottom)
                    }
                    .ignoresSafeArea()
            }
            .fullScreenCover(isPresented: $isCameraPresented) {
                ImagePicker(selectedImage: $selectedImage, sourceType: .camera).ignoresSafeArea()
            }
            

            .navigationBarTitle("New Reply")


            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Menu("", systemImage: "ellipsis.circle") {
                            Button {
                                showingDatePicker.toggle()

                            } label: {
                                Label("Edit Date", systemImage: "calendar")
                            }
                            
                            Button {
                                showingReminderSheet = true

                            } label: {
                                Label("Set Reminder", systemImage: "bell.fill")
                            }
                        }

                        .sheet(isPresented: $showingDatePicker) {
                            dateEditSheet()
                        }
                        .sheet(isPresented: $showingReminderSheet) {
                            reminderSheet()
                            .onAppear {
                                if let reminderId = reminderId {
                                    fetchAndInitializeReminderDetails(reminderId: reminderId)
                                }
                                requestReminderAccess { granted in
                                    if granted {
                                        hasReminderAccess = true
                                        print("Access to reminders granted.")
                                    } else {
                                        hasReminderAccess = false
                                        print("Access to reminders denied or failed.")
                                    }
                                }
                            }
                        }

            
                        Button(action: {
                            vibration_heavy.impactOccurred()
                            
                            finalizeCreation()
                            presentationMode.wrappedValue.dismiss()
                            focusField = false
                            keyboardHeight = 0
                        }) {
                            Text("Done")
//                                .font(.system(size: 15))
                                .foregroundColor(userPreferences.accentColor)
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        vibration_heavy.impactOccurred()
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
//                            .font(.system(size: 15))
                    }
                }
            }
            .font(.system(size: UIFont.systemFontSize))
   
        }
        
        .onTapGesture {
            focusField = true
            keyboardHeight = UIScreen.main.bounds.height/3
        }
       
    }
    
    
    func createOrUpdateReminder() {
        let eventStore = EKEventStore()
        let combinedDateTime = Calendar.current.date(bySettingHour: Calendar.current.component(.hour, from: selectedTime), minute: Calendar.current.component(.minute, from: selectedTime), second: 0, of: selectedReminderDate) ?? Date()

        eventStore.requestAccess(to: .reminder) { granted, error in
            guard granted, error == nil else {
                print("Access to reminders denied or failed.")
                showingReminderSheet = false
                return
            }

            if let reminderId = self.reminderId, reminderExists(with: reminderId, in: eventStore) {
                // Existing reminder found, update it
                editAndSaveReminder(reminderId: reminderId, title: reminderTitle.isEmpty ? "Reminder" : reminderTitle, dueDate: combinedDateTime, recurrenceOption: selectedRecurrence) { success, updatedReminderId in
                    if success, let updatedReminderId = updatedReminderId {
                        self.reminderId = updatedReminderId
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
                        self.reminderId = newReminderId
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


    
    func requestReminderAccess(completion: @escaping (Bool) -> Void) {
        let eventStore = EKEventStore()
        eventStore.requestAccess(to: .reminder) { granted, error in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }

    func editAndSaveReminder(reminderId: String?, title: String, dueDate: Date, recurrenceOption: String, completion: @escaping (Bool, String?) -> Void) {
        let eventStore = EKEventStore()

        eventStore.requestAccess(to: .reminder) { granted, error in
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


    
    func requestCalendarAccess(completion: @escaping (Bool) -> Void) {
        let eventStore = EKEventStore()
        eventStore.requestAccess(to: .event) { (granted, error) in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }

    func createRecurrenceRule(fromOption option: String) -> EKRecurrenceRule? {
        switch option {
        case "Daily":
            return EKRecurrenceRule(recurrenceWith: .daily, interval: 1, end: nil)
        case "Weekly":
            return EKRecurrenceRule(recurrenceWith: .weekly, interval: 1, end: nil)
        case "Weekends":
            let rule = EKRecurrenceRule(recurrenceWith: .weekly, interval: 1, daysOfTheWeek: [EKRecurrenceDayOfWeek(.saturday), EKRecurrenceDayOfWeek(.sunday)], daysOfTheMonth: nil, monthsOfTheYear: nil, weeksOfTheYear: nil, daysOfTheYear: nil, setPositions: nil, end: nil)
            return rule
        case "Biweekly":
            return EKRecurrenceRule(recurrenceWith: .weekly, interval: 2, end: nil)
        case "Monthly":
            return EKRecurrenceRule(recurrenceWith: .monthly, interval: 1, end: nil)
        default:
            return nil
        }
    }
    
    func fetchAndInitializeReminderDetails(reminderId: String?) {
        guard let reminderId = reminderId, !reminderId.isEmpty else { return }

        let eventStore = EKEventStore()
        eventStore.requestAccess(to: .reminder) { granted, error in
            guard granted, error == nil else {
                print("Access to reminders denied or failed.")
                return
            }
            
            DispatchQueue.main.async {
                if let reminder = eventStore.calendarItem(withIdentifier: reminderId) as? EKReminder {
                    // Update title
                    reminderTitle = reminder.title ?? ""
                    
                    // Update date and time if dueDateComponents is available
                    if let dueDateComponents = reminder.dueDateComponents,
                       let dueDate = Calendar.current.date(from: dueDateComponents) {
                        selectedReminderDate = dueDate
                        selectedReminderTime = dueDate
                    }
                    
                    // Update recurrence option if a recurrence rule is available
                    if let recurrenceRule = reminder.recurrenceRules?.first,
                       let recurrenceOption = mapRecurrenceRuleToOption(recurrenceRule) {
                        selectedRecurrence = recurrenceOption
                    }
                }
            }
        }
    }
    func mapRecurrenceRuleToOption(_ rule: EKRecurrenceRule) -> String? {
        switch rule.frequency {
        case .daily:
            return "Daily"
        case .weekly:
            if rule.daysOfTheWeek?.count == 2,
               rule.daysOfTheWeek?.contains(EKRecurrenceDayOfWeek(.saturday)) == true,
               rule.daysOfTheWeek?.contains(EKRecurrenceDayOfWeek(.sunday)) == true {
                return "Weekends"
            }
            return "Weekly"
        case .monthly:
            return "Monthly"
        default:
            return nil
        }
    }
    
    @ViewBuilder
    func finalRepliedView() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                Spacer()

                repliedEntryView().padding([.leading, .top, .bottom]).padding([.leading, .top])
                    .overlay {
                        VStack {
                            Spacer()
                            HStack {
                                UpperLeftCornerShape(cornerRadius: 20, extendLengthX: 6, extendLengthY: 6)
                                    .stroke(lineWidth: 2)
                                    .foregroundStyle(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color(UIColor.label))).opacity(0.13))
                                    .frame(maxWidth: .infinity, maxHeight: 5) // Correctly size the frame based on the shape dimensions
                                Spacer()
                            }
                        }.padding(.bottom)
                    }
               

            }.padding(.horizontal)
            textFieldView()
            Spacer()
           }
    }
    
    @ViewBuilder
    func textFieldView() -> some View {
        
        VStack (alignment: .leading) {

            ZStack {
                if entryContent.isEmpty {
                    VStack {
                        HStack {
                            Text("Start typing here...")
                                .foregroundStyle(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color(UIColor.label))).opacity(0.3))
                                .font(.custom(userPreferences.fontName, size: userPreferences.fontSize))
                            Spacer()
                        }.padding(20)
                        Spacer()
                    }
                }
                GrowingTextField(
                    attributedText: $entryContent.asAttributedString(
                        fontName: userPreferences.fontName,
                        fontSize: userPreferences.fontSize,
                        fontColor: UIColor(
                            UIColor.foregroundColor(
                                background: UIColor(userPreferences.backgroundColors.first ?? Color.clear)
                            )
                        )
                    ),
                    fontName: userPreferences.fontName,
                    fontSize: userPreferences.fontSize,
                    fontColor: UIColor(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color.clear))),
                    cursorColor: UIColor(userPreferences.accentColor),
                    backgroundColor: UIColor(userPreferences.backgroundColors.first ?? .black),
                    cursorPosition: $cursorPosition,
                    viewModel: textEditorViewModel
                )
                .cornerRadius(15)
      
       
                     
            }
            
            HStack {
//                ZStack(alignment: .topTrailing) {
//                    repliedEntryView().padding(10).scaledToFit()
//                        .onAppear {
//                            print("REPLY ID: \(replyEntryId)")
//                        }
//                    
////                    if !replyEntryId.isEmpty {
////                        Button(role: .destructive, action: {
//////                            vibration_light.impactOccurred()
//////                            replyEntryId = ""
////                        }) {
//////                            Image(systemName: "x.circle").foregroundColor(.red.opacity(0.9)).frame(width: 25, height: 25).padding(15)                            .foregroundColor(.red)
////                            Spacer().padding(15)
////                        }
////                    }
//                }
                entryMediaView().cornerRadius(15.0).padding(10).scaledToFit().frame(minHeight: 0)
             
      
            }
        }.background {
            ZStack {
                Color(UIColor(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color(UIColor.label))))).opacity(0.05)
            }.ignoresSafeArea(.all)
        }.cornerRadius(15)
            .padding([.leading, .trailing, .top])
//        .padding()
        .onSubmit {
            finalizeCreation()
        }
    }
    
    @ViewBuilder
    func dateEditSheet() -> some View {
        VStack {
            HStack {
                Button("Cancel") {
                    showingDatePicker = false
                }.foregroundStyle(.red)
                Spacer()
                Button("Done") {
                    // Perform the action when the date is selected
                    showingDatePicker = false
                }.foregroundStyle(Color(UIColor.label))
            }
            .font(.system(size: 15))
            .padding()
        }
    List {

        DatePicker("Edit Date", selection: $selectedDate)
            .presentationDetents([.fraction(0.25)])
            .font(.system(size: 15))
            .foregroundColor(userPreferences.accentColor)
            .padding(.horizontal)
    }.navigationTitle("Select Custom Date")
    }

    @ViewBuilder
    func reminderSheet() -> some View {
        NavigationStack {
            if hasReminderAccess {
                List {
                    Section {
                        TextField("Title", text: $reminderTitle)
                            .background(Color.clear) // Set the background to clear
                               .textFieldStyle(PlainTextFieldStyle()) // Use
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(colorScheme == .dark ? Color.white : Color.black)

                    }
                    Section {
                        DatePicker("Date", selection: $selectedReminderDate, displayedComponents: .date)
                        DatePicker("Time", selection: $selectedReminderTime, displayedComponents: .hourAndMinute)

                    }
                    .foregroundStyle(colorScheme == .dark ? Color.white : Color.black)
                    .accentColor(userPreferences.accentColor)

                    NavigationLink {
                        List {
                            Picker("Recurrence", selection: $selectedRecurrence) {
                                ForEach(recurrenceOptions, id: \.self) { option in
                                    Text(option).tag(option)
                                }
                            }
                            .font(.system(size: 15))
                            .pickerStyle(.inline)
                            .accentColor(userPreferences.accentColor)

                        }
                    } label: {
                        Label("Repeat", systemImage: "repeat")
                    }
      
                    .font(.system(size: 15))
                    .foregroundStyle(colorScheme == .dark ? Color.white : Color.black)
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
                    
                .alert("Are you sure you want to delete this reminder?", isPresented: $showDeleteReminderAlert) {
                          Button("Delete", role: .destructive) {
                              // Call your delete reminder function here
                              deleteReminder(reminderId: reminderId)
                              showingReminderSheet = false
                          }
                          Button("Cancel", role: .cancel) {}
                      } message: {
                          Text("This action cannot be undone.")
                      }
                
                .background {
                        ZStack {
                            Color(UIColor.systemGroupedBackground)
                                .ignoresSafeArea()
                        }
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
            }
        }
    }
    
    @ViewBuilder
    func entrySectionHeader(entry: Entry) -> some View {
        HStack {
                Text("\(entry.isPinned && formattedDate(entry.time) != formattedDate(Date()) ? formattedDateShort(from: entry.time) : formattedTime(time: entry.time))")
                .foregroundStyle(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color(UIColor.label)))).opacity(0.4)
                if let timeLastUpdated = entry.lastUpdated {
                    if formattedTime_long(date: timeLastUpdated) != formattedTime_long(date: entry.time), userPreferences.showMostRecentEntryTime {
                        HStack {
                            Image(systemName: "arrow.right")
                            Text(formattedTime_long(date: timeLastUpdated))
                        }
                        .foregroundStyle(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color(UIColor.label)))).opacity(0.4)
                    }

                }

            Image(systemName: entry.stampIcon).foregroundStyle(Color(entry.color))
            Spacer()
            
            if let reminderId = entry.reminderId, !reminderId.isEmpty, entry_1.reminderExists(with: reminderId) {
                
                Label("", systemImage: "bell.fill").foregroundColor(userPreferences.reminderColor)
            }

            if (entry.isPinned) {
                Label("", systemImage: "pin.fill").foregroundColor(userPreferences.pinColor)

            }
        }
        .font(.system(size: max(UIFont.systemFontSize*0.8,5)))

    }
    
    func getIdealTextColor() -> Color {
        var entryBackgroundColor =  UIColor(userPreferences.entryBackgroundColor)
        var backgroundColor = isClear(for: UIColor(userPreferences.backgroundColors.first ?? Color.clear)) ? getDefaultBackgroundColor(colorScheme: colorScheme) : userPreferences.backgroundColors.first ?? Color.clear
        var blendedBackground = UIColor.blendedColor(from: entryBackgroundColor, with: UIColor(backgroundColor))
        return Color(UIColor.fontColor(forBackgroundColor: blendedBackground))
    }
    
    @ViewBuilder
    func repliedEntryView() -> some View {
        if !replyEntryId.isEmpty {
            if let repliedEntry = fetchEntryById(id: replyEntryId, coreDataManager: coreDataManager) {
                
                VStack(alignment: .trailing) {
                                    entrySectionHeader(entry: repliedEntry)
                        NotEditingView_thumbnail(entry: repliedEntry, foregroundColor: UIColor(getDefaultEntryBackgroundColor(colorScheme: colorScheme)))
                            .environmentObject(userPreferences)
                            .environmentObject(coreDataManager)
                            .background(Color(UIColor.backgroundColor(entry: repliedEntry, colorScheme: colorScheme, userPreferences: userPreferences)))
                            .cornerRadius(15.0)
                            .frame(maxWidth: .infinity)
                            .overlay(
                                  RoundedRectangle(cornerRadius: 15)
                                      .stroke(getIdealTextColor().opacity(0.05), lineWidth: 2)
                            )
                        
          
                    
                }.scaledToFit()
            }
        }
    }


    @ViewBuilder
    func entryMediaView() -> some View {
        ZStack(alignment: .topTrailing) {
        if let data = selectedData {
            if isGIF(data: data) {
                AnimatedImageView_data(data: data)
                    .contextMenu {
                        Button(role: .destructive, action: {
                                selectedData = nil
                                imageHeight = 0
                        }) {
                            Text("Delete")
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
            } else if isPDF(data: data) { // Assuming you have an
                    PDFKitView(data: data)
                        .contextMenu {
                            Button(role: .destructive, action: {
                                    selectedData = nil
                                    imageHeight = 0
                            }) {
                                Text("Delete")
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
         
            } else {
                CustomAsyncImageView_uiImage(image: UIImage(data: data)!)
                    .contextMenu {
                        Button(role: .destructive, action: {
                                selectedData = nil
                                imageHeight = 0
                        }) {
                            Text("Delete")
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
            }
        }
            if selectedData != nil {
                Button(role: .destructive, action: {
                    vibration_light.impactOccurred()
                    selectedData = nil
                    imageHeight = 0
                }) {
                    Image(systemName: "x.circle").foregroundColor(.red.opacity(0.9)).frame(width: 25, height: 25).padding(2)
                        .foregroundColor(.red)
                }
            }
            
        }
    }
    @ViewBuilder
    func textFormattingButtonBar() -> some View {
        HStack(spacing: 35) {
            // Bullet Point Button
            Button(action: {
                self.textEditorViewModel.textToInsert = "\t• "
            }) {
                Image(systemName: "list.bullet")
                    .font(.system(size: 20))
                    .foregroundColor(userPreferences.accentColor)
            }

            // Tab Button
            Button(action: {
                // Signal to insert a tab character.
                self.textEditorViewModel.textToInsert = "\t"
            }) {
                Image(systemName: "arrow.forward.to.line")
                    .font(.system(size: 20))
                    .foregroundColor(userPreferences.accentColor)
            }

            // New Line Button
            Button(action: {
                // Signal to insert a new line.
                self.textEditorViewModel.textToInsert = "\n"
            }) {
                Image(systemName: "return")
                    .font(.system(size: 20))
                    .foregroundColor(userPreferences.accentColor)
            }

            Spacer()
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 20)
  
        .background(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color(UIColor.label))).opacity(0.05)).ignoresSafeArea(.all)
        .cornerRadius(15)
    }

    @ViewBuilder
    func buttonBar() -> some View {
        HStack(spacing: 35) {
            
            
            Button(action: startOrStopRecognition) {
                Image(systemName: "mic.fill")
                    .foregroundColor(!isListening ? userPreferences.accentColor : Color.complementaryColor(of: userPreferences.accentColor))
                    .font(.system(size: 20))
            }
            Spacer()
        
            Button {
                vibration_heavy.impactOccurred()
                isHidden.toggle()
            } label: {
                Image(systemName: isHidden ? "eye.slash.fill" : "eye.fill")
                    .font(.system(size: 20))
                    .foregroundColor(userPreferences.accentColor).opacity(isHidden ? 1 : 0.1)
            }
            
            
            PhotosPicker(selection:$selectedItem, matching: .images) {
                Image(systemName: "photo.fill")
                    .font(.system(size: 20))

            }
            .onChange(of: selectedItem) { _ in
                selectedData = nil
                Task {
                    if let data = try? await selectedItem?.loadTransferable(type: Data.self) {
                        selectedData = data
                        imageHeight = UIScreen.main.bounds.height/7
                    }
                }
            }

            
            Image(systemName: "camera.fill")
                .font(.system(size: 20))
                .onChange(of: selectedImage) { _ in
                    selectedData = nil
                    Task {
                        if let data = selectedImage?.jpegData(compressionQuality: 0.7) {
                            selectedData = data
                            imageHeight = UIScreen.main.bounds.height/7
                        }
                    }
                }
                .onTapGesture {
                    vibration_heavy.impactOccurred()
                    isCameraPresented = true
                }
            
            Button {
                selectedData = nil
                vibration_heavy.impactOccurred()
                isDocumentPickerPresented = true
            } label: {
                Image(systemName: "link")
                    .font(.system(size: 20))
            }
            .fileImporter(
                isPresented: $isDocumentPickerPresented,
                allowedContentTypes: [UTType.image, UTType.pdf], // Customize as needed
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    let url = urls[0]
                    do {
                        // Attempt to start accessing the security-scoped resource
                        if url.startAccessingSecurityScopedResource() {
                            // Here, instead of creating a bookmark, we read the file data directly
                            let fileData = try Data(contentsOf: url)
                            selectedData = fileData // Assuming selectedData is of type Data
                            imageHeight = UIScreen.main.bounds.height/7
                            
                            if isPDF(data: fileData) {
                                selectedPDFLink = url
                            }
                            
                            // Remember to stop accessing the security-scoped resource when you’re done
                            url.stopAccessingSecurityScopedResource()
                        } else {
                            // Handle failure to access the file
                            print("Error accessing file")
                        }
                    } catch {
                        // Handle errors such as file not found, insufficient permissions, etc.
                        print("Error reading file: \(error)")
                    }
                case .failure(let error):
                    // Handle the case where the document picker failed to return a file
                    print("Error selecting file: \(error)")
                }
            }
            
            
            
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 20)
        .background {
            ZStack {
                Color.clear
                LinearGradient(colors: [UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color(UIColor.label))).opacity(0.05), Color.clear], startPoint: .top, endPoint: .bottom)
            }
            .ignoresSafeArea()
        }

    }
    
    func finalizeCreation() {
        let newEntry = Entry(context: viewContext)
        newEntry.id = UUID()
        newEntry.content = entryContent
        newEntry.time = selectedDate
        newEntry.lastUpdated = nil
        print("entry time has been set")
        newEntry.stampIndex = -1
        
        newEntry.color = UIColor.clear
        newEntry.stampIcon = ""
        newEntry.isHidden = isHidden
        newEntry.isRemoved = false
        newEntry.isDrafted = false
        newEntry.isPinned = false
        newEntry.isShown = true
        newEntry.shouldSyncWithCloudKit = false
        
    
        
        if let data = selectedData {
            if let savedFilename = saveMedia(data: data) {
                newEntry.mediaFilename = savedFilename
                newEntry.mediaFilenames = [savedFilename] //
            } else {
                print("Failed to save media.")
            }
        }
        
        if let reminderId {
            newEntry.reminderId = reminderId
        }
        
        if !replyEntryId.isEmpty {
            newEntry.entryReplyId = replyEntryId
        }

        // Fetch the log with the appropriate day
        let fetchRequest: NSFetchRequest<Log> = Log.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "day == %@", formattedDate(newEntry.time))
        
        do {
            let logs = try viewContext.fetch(fetchRequest)
            print("LOGS: ", logs)
            if let log = logs.first {
                log.addToRelationship(newEntry)
                newEntry.relationship = log
            } else {
                // Create a new log if needed
                let dateStringManager = DateStrings()
                let newLog = Log(context: viewContext)
                newLog.day = formattedDate(newEntry.time)
                dateStringManager.addDate(newLog.day)
                newLog.addToRelationship(newEntry)
                newLog.id = UUID()
                newEntry.relationship = newLog
                
                let todayDate = Date()
                let todayComponents = Calendar.current.dateComponents([.year, .month, .day], from: Date())
                let todayDateString = formattedDate(todayDate)  // Using formattedDate function
                datesModel.dates.append(LogDate(date: todayComponents, isSelected: false, hasLog: true))  // Start with today not selected
            }
            try viewContext.save()
        } catch {
            print("Error saving new entry: \(error)")
        }
    }
    
    func startRecognition() {
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        let recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        let inputNode = audioEngine.inputNode
        
        // Remove existing taps if any
        inputNode.removeTap(onBus: 0)
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, _ in
            if let result = result {
                entryContent = result.bestTranscription.formattedString
            }
        }
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: inputNode.outputFormat(forBus: 0)) { (buffer: AVAudioPCMBuffer, _) in
            recognitionRequest.append(buffer)
        }
        audioEngine.prepare()
        try? audioEngine.start()
    }
    
    func stopRecognition() {
        audioEngine.stop()
        recognitionTask?.cancel()
    }
    func startOrStopRecognition() {
        isListening.toggle()
        if isListening {
            startRecognition()
        }
        else {
            stopRecognition()
        }
    }
    func deleteImage() {
        if filename != "" {
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsDirectory.appendingPathComponent(filename)
            do {
                print("file URL from deleteImage: \(fileURL)")
                try FileManager.default.removeItem(at: fileURL)
            } catch {
                print("Error deleting image file: \(error)")
            }
        }
        
        selectedImage = nil
        selectedData = nil
        
        
        do {
            try viewContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
}
