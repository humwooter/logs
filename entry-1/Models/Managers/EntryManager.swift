////
////  EntryManager.swift
////  entry-1
////
////  Created by Katyayani G. Raman on 7/10/24.
////
//import SwiftUI
//import CoreData
//import Combine
//
//class EntryManager: ObservableObject {
//    private let context: NSManagedObjectContext
//    @ObservedObject var userPreferences: UserPreferences
//    private var cancellables = Set<AnyCancellable>()
//    
//    init(context: NSManagedObjectContext, userPreferences: UserPreferences) {
//        self.context = context
//        self.userPreferences = userPreferences
//        
//        setupPreferenceObservers()
//    }
//    
//    private func setupPreferenceObservers() {
//        userPreferences.$showLinks
//            .sink { [weak self] _ in
//                self?.updateAllEntriesAttributes()
//            }
//            .store(in: &cancellables)
//        
//        userPreferences.$fontSize
//            .sink { [weak self] _ in
//                self?.updateAllEntriesAttributes()
//            }
//            .store(in: &cancellables)
//        
//        userPreferences.$fontName
//            .sink { [weak self] _ in
//                self?.updateAllEntriesAttributes()
//            }
//            .store(in: &cancellables)
//    }
//    
//    private func updateAllEntriesAttributes() {
//        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
//        
//        do {
//            let entries = try context.fetch(fetchRequest)
//            for entry in entries {
//                updateEntryAttributes(entry)
//            }
//            try context.save()
//        } catch {
//            print("Failed to fetch or update entries: \(error)")
//        }
//    }
//    
//    private func updateEntryAttributes(_ entry: Entry) {
//        guard let attributedContent = entry.attributedContent else { return }
//        
//        let mutableAttributedString = NSMutableAttributedString(attributedString: attributedContent)
//        let fullRange = NSRange(location: 0, length: mutableAttributedString.length)
//        
//        // Apply font
//        let font = UIFont(name: userPreferences.fontName, size: CGFloat(userPreferences.fontSize)) ?? UIFont.systemFont(ofSize: CGFloat(userPreferences.fontSize))
//        mutableAttributedString.addAttribute(NSAttributedString.Key.font, value: font, range: fullRange)
//        
//        // Apply link attributes if showLinks is true
//        if userPreferences.showLinks {
//            mutableAttributedString.enumerateAttribute(NSAttributedString.Key.link, in: fullRange, options: []) { value, range, _ in
//                if let url = value as? URL {
//                    mutableAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.blue, range: range)
//                    mutableAttributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
//                }
//            }
//        } else {
//            // Remove link styling if showLinks is false
//            mutableAttributedString.removeAttribute(NSAttributedString.Key.link, range: fullRange)
//            mutableAttributedString.removeAttribute(NSAttributedString.Key.foregroundColor, range: fullRange)
//            mutableAttributedString.removeAttribute(NSAttributedString.Key.underlineStyle, range: fullRange)
//        }
//        
//        entry.attributedContent = mutableAttributedString
//    }
//    
//    func addEntry(title: String, content: String) {
//        let newEntry = Entry(context: context)
//        newEntry.id = UUID()
//        newEntry.title = title
//        newEntry.attributedContent = NSAttributedString(string: content)
//        
//        updateEntryAttributes(newEntry)
//        
//        do {
//            try context.save()
//        } catch {
//            print("Failed to save new entry: \(error)")
//        }
//    }
//    
//    func updateEntry(_ entry: Entry) {
//        updateEntryAttributes(entry)
//        
//        do {
//            try context.save()
//        } catch {
//            print("Failed to update entry: \(error)")
//        }
//    }
//}
