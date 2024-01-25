//
//  SearchViews.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 12/28/23.
//

import Foundation
import SwiftUI




class SearchModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var tokens: [FilterTokens] = []
}

enum FilterTokens: String, Identifiable, Hashable, CaseIterable {
    case hiddenEntries, stampNameEntries, stampIndexEntries, mediaEntries, searchTextEntries
    var id: Self { self }
}
