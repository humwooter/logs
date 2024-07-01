//
//  EntryManagement.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 7/1/24.
//

import Foundation


protocol EntryManagement {
    func finalizeEntry()
    func cancelEntry()
}

extension EditingEntryView: EntryManagement {
    func finalizeEntry() {
        // Implementation
    }
    
    func cancelEntry() {
        // Implementation
    }
}

extension NewEntryView: EntryManagement {
    func finalizeEntry() {
        // Implementation
    }
    
    func cancelEntry() {
        // Implementation
    }
}
