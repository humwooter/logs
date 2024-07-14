//
//  RichEditorState.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 7/11/24.
//

import Foundation
import Combine
import UIKit
import Foundation
import Combine

public class RichEditorState: ObservableObject {
    @Published internal var editableText: NSMutableAttributedString
    @Published internal var activeStyles: Set<RichTextStyle> = []
    @Published internal var activeAttributes: [NSAttributedString.Key: Any]? = [:]
    internal var currentFont: FontRepresentable = .systemFont(ofSize: 14)

    @Published internal var attributesToApply: ((spans: [(span: RichTextSpanInternal, shouldApply: Bool)], onCompletion: () -> Void))? = nil

    private var activeSpans: [RichTextSpanInternal] = []

    private var highlightedRange: NSRange
    private var rawText: String

    public var richText: RichText {
        return getRichText()
    }

    public init(editableText: NSMutableAttributedString, highlightedRange: NSRange, rawText: String) {
        self.editableText = editableText
        self.highlightedRange = highlightedRange
        self.rawText = rawText
    }
    
    func getTypingAttributesForStyles(_ styles: Set<RichTextStyle>) -> [NSAttributedString.Key: Any] {
        var font = currentFont
        var attributes: [NSAttributedString.Key: Any] = [:]

        styles.forEach {
            if $0.attributedStringKey == .font {
                font = $0.getFontWithUpdating(font: font)
                attributes[$0.attributedStringKey] = font
            } else {
                attributes[$0.attributedStringKey] = $0.defaultAttributeValue(font: font)
            }
        }
        return attributes
    }


    private func getRichText() -> RichText {
        var spans: [RichText.RichTextSpan] = []
        for span in activeSpans {
            let text = (editableText.string as NSString).substring(with: span.spanRange)
            let richTextSpan = RichText.RichTextSpan(insert: text, attributes: span.attributes ?? RichTextAttributes(header: nil, styles: { [] }))
            spans.append(richTextSpan)
        }
        return RichText(spans: spans)
    }
}


public struct RichTextSpanInternal {
    var spanRange: NSRange
    var attributes: RichTextAttributes?
}


public struct RichTextAttributes {
    var header: String?
    var styles: () -> [RichTextStyle]
}
