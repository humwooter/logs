//
//  UserPreferences.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 10/14/23.
//
//

import Foundation
import SwiftData


@Model public class UserPreferences {
    var color: NSObject?
    var font: String?
    var fontsize: Int16? = 0
    

    public init() { }
    
}
