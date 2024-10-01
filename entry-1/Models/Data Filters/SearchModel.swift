//
//  SearchViews.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 12/28/23.
//

import Foundation
import SwiftUI
import UIKit




class SearchModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var tokens: [FilterType] = []
}
//
//enum FilterTokens: String, Identifiable, Hashable, CaseIterable {
//    case hiddenEntries, stampNameEntries, stampIndexEntries, mediaEntries, reminderEntries, pinnedEntries, searchTextEntries
//    var id: Self { self }
//}

enum FilterType: Identifiable {
    case content(String)
    case title(String)
    case time(Date, Date)
    case lastUpdated(Date, Date)
    case color(UIColor)
    case tagNames([String])
    case isHidden(Bool)
    case hasMedia(Bool)
    case hasReminder(Bool)
    case isShown(Bool)
    case isPinned(Bool)
    case isRemoved(Bool)
    case isDrafted(Bool)
    case shouldSyncWithCloudKit(Bool)
    case stampIcon(String)
    case folderId(String)
    case tag(String)
    case date(Date)

    var id: String {
        switch self {
        case .content(let string):
            return "content_\(string)"
        case .title(let string):
            return "title_\(string)"
        case .time(let start, let end):
            return "time_\(start.timeIntervalSince1970)_\(end.timeIntervalSince1970)"
        case .lastUpdated(let start, let end):
            return "lastUpdated_\(start.timeIntervalSince1970)_\(end.timeIntervalSince1970)"
        case .color(let color):
            return "color_\(color.hashValue)"
        case .tagNames(let tags):
            return "tagNames_\(tags.joined(separator: "_"))"
        case .isHidden(let value):
            return "isHidden_\(value)"
        case .hasMedia(let value):
            return "hasMedia_\(value)"
        case .hasReminder(let value):
            return "hasReminder_\(value)"
        case .isShown(let value):
            return "isShown_\(value)"
        case .isPinned(let value):
            return "isPinned_\(value)"
        case .isRemoved(let value):
            return "isRemoved_\(value)"
        case .isDrafted(let value):
            return "isDrafted_\(value)"
        case .shouldSyncWithCloudKit(let value):
            return "shouldSyncWithCloudKit_\(value)"
        case .stampIcon(let string):
            return "stampIcon_\(string)"
        case .folderId(let string):
            return "folderId_\(string)"
        case .tag(let string):
            return "tag_\(string)"
        case .date(let date):
            return "date_\(date.timeIntervalSince1970)"
        }
    }
}
