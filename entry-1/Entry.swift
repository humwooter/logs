//
//  Entry.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 10/14/23.
//
//

import Foundation
import SwiftData


@Model public class Entry {
    var isRemoved: Bool?
    var buttons: NSObject?
    var color: NSObject?
    var content: String?
    var id: UUID?
    var image: String?
    var imageContent: String?
    var isHidden: Bool?
    var time: Date?
    var relationship: Log?
    

    public init() { }
    
}
