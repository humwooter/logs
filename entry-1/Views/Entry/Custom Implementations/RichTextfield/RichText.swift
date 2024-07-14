//
//  RichText.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 7/11/24.
//

import Foundation

public struct RichText {
    var spans: [RichTextSpan]

    public struct RichTextSpan {
        var insert: String
        var attributes: RichTextAttributes
    }
}
