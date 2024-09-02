//
//  TagViewModel.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 8/30/24.
//
import SwiftUI
import CoreData

class TagViewModel: ObservableObject {
    @Published var currentTags: [String: Bool] = [:]
    private var coreDataManager: CoreDataManager
    
    init(coreDataManager: CoreDataManager) {
        self.coreDataManager = coreDataManager
    }
    
    func getSelectedTags() -> [String] {
        return currentTags.filter { $0.value }.keys.sorted()
    }
    
    func saveSelectedTags(for entry: Entry) {
        entry.tagNames = getSelectedTags()
        
        updateTagCounts()
        
        do {
            try coreDataManager.viewContext.save()
        } catch {
            print("Error saving selected tags: \(error)")
        }
    }
    
    func saveSelectedTags(to selectedTags: inout [String]) {
        selectedTags = getSelectedTags()
    }
    
    func updateTagCounts() {
        let fetchRequest: NSFetchRequest<Tag> = Tag.fetchRequest()
        
        do {
            let allTags = try coreDataManager.viewContext.fetch(fetchRequest)
            
            for (tagName, isSelected) in currentTags {
                if let tag = allTags.first(where: { $0.name == tagName }) {
                    if isSelected {
                        tag.numEntries += 1
                    } else {
                        tag.numEntries = max(0, tag.numEntries - 1)
                    }
                } else if isSelected {
                    // Create new tag if it doesn't exist
                    let newTag = Tag(context: coreDataManager.viewContext)
                    newTag.name = tagName
                    newTag.numEntries = 1
                    newTag.id = UUID()
                }
            }
            
            try coreDataManager.viewContext.save()
        } catch {
            print("Error updating tag counts: \(error)")
        }
    }
    
    func initializeCurrentTags(with selectedTags: [String]) {
        let fetchRequest: NSFetchRequest<Tag> = Tag.fetchRequest()
        
        do {
            let allTags = try coreDataManager.viewContext.fetch(fetchRequest)
            
            for tag in allTags {
                if let name = tag.name {
                    currentTags[name] = selectedTags.contains(name)
                }
            }
        } catch {
            print("Error fetching tags: \(error)")
        }
    }
    
    func toggleTagSelection(_ tagName: String) {
        currentTags[tagName]?.toggle()
    }
    
    func addNewTag(_ tagName: String) {
        print("in add new tag")
        guard !tagName.isEmpty else { return }
        
        let formattedTagName = formatToTagReadableString(tagName)
        
        // Check if the tag already exists in Core Data
        let fetchRequest: NSFetchRequest<Tag> = Tag.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", formattedTagName)
        
        do {
            let existingTags = try coreDataManager.viewContext.fetch(fetchRequest)
            if existingTags.isEmpty {
                // Create new tag if it doesn't exist
                let newTag = Tag(context: coreDataManager.viewContext)
                newTag.name = formattedTagName
                newTag.numEntries = 1
                newTag.id = UUID()
                currentTags[formattedTagName] = true

                try coreDataManager.viewContext.save()
                print("Created new tag: \(formattedTagName)")
            } else {
                print("Tag already exists: \(formattedTagName)")
            }
        } catch {
            print("Error checking for existing tag: \(error)")
        }
        if !currentTags.keys.contains(formattedTagName) {
            currentTags[formattedTagName] = true
        }

    }
    
    private func formatToTagReadableString(_ input: String) -> String {
        return input
            .lowercased()
            .replacingOccurrences(of: " ", with: "-")
    }
}
