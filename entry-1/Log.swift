//
//  Log.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 10/14/23.
//
//

import Foundation
import SwiftData


@Model public class Log {
    var day: String?
    var id: UUID?
    @Relationship(deleteRule: .cascade) var relationship: [Entry]?
    

    public init() { }
    
}
