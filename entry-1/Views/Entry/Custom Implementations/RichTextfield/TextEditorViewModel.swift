//
//  TextEditorViewModel.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 7/11/24.
//
//
import Combine
import SwiftUI


class TextEditorViewModel: ObservableObject {
    @Published var attributedText: NSAttributedString = NSAttributedString(string: "")
    @Published var selectedRange: NSRange = NSRange(location: 0, length: 0)
    @Published var activeAttributes: [NSAttributedString.Key: Any] = [:]
    @Published var attributesToApply: ((spans: [(span: RichTextSpanInternal, shouldApply: Bool)], onCompletion: () -> Void))?

    func applyStyle(_ style: RichTextStyle) {
        let spans = [(span: RichTextSpanInternal(spanRange: selectedRange, attributes: RichTextAttributes(header: nil, styles: { [style] })), shouldApply: true)]
        attributesToApply = (spans: spans, onCompletion: {})
    }

    func insertText(_ text: NSAttributedString, at range: NSRange) {
        let mutableAttributedString = NSMutableAttributedString(attributedString: attributedText)
        mutableAttributedString.replaceCharacters(in: range, with: text)
        attributedText = mutableAttributedString
    }

    func getTypingAttributesForStyles(_ styles: Set<RichTextStyle>) -> [NSAttributedString.Key: Any] {
        var attributes: [NSAttributedString.Key: Any] = [:]
        styles.forEach { style in
            attributes[style.attributedStringKey] = style.defaultAttributeValue()
        }
        return attributes
    }
}

//
//class TextEditorViewModel: ObservableObject {
//    @Published var text: String = ""
//    @Published var attributedText: NSAttributedString = NSAttributedString(string: "")
//    @Published var textToInsert: NSAttributedString?
//    @Published var selectedRange: NSRange = NSRange(location: 0, length: 0)
//    @Published var styleToApply: TextStyle?
//    @Published var activeAttributes: [NSAttributedString.Key: Any]? = [:]
//    @Published var attributesToApply: ((spans: [(span: RichTextSpanInternal, shouldApply: Bool)], onCompletion: () -> Void))? = nil
//
//    enum TextStyle {
//        case bold, italic, underline
//    }
//
//    func applyStyle(_ style: TextStyle) {
//        styleToApply = style
//    }
//
//    func updateSelectedRange(_ range: NSRange) {
//        selectedRange = range
//    }
//
//    func insertText(_ text: NSAttributedString, at range: NSRange) {
//        let mutableAttributedString = NSMutableAttributedString(attributedString: attributedText)
//        mutableAttributedString.replaceCharacters(in: range, with: text)
//        attributedText = mutableAttributedString
//    }
//
//    func insertText() {
//        guard let textToInsert = textToInsert else { return }
//        let mutableAttributedString = NSMutableAttributedString(attributedString: attributedText)
//        let range = selectedRange
//        mutableAttributedString.replaceCharacters(in: range, with: textToInsert)
//        attributedText = mutableAttributedString
//        self.textToInsert = nil
//    }
//
//    func getTypingAttributesForStyles(_ styles: Set<RichTextStyle>) -> [NSAttributedString.Key: Any] {
//        var font = UIFont.systemFont(ofSize: 14)
//        var attributes: [NSAttributedString.Key: Any] = [:]
//
//        styles.forEach {
//            if $0.attributedStringKey == .font {
//                font = $0.getFontWithUpdating(font: font)
//                attributes[$0.attributedStringKey] = font
//            } else {
//                attributes[$0.attributedStringKey] = $0.defaultAttributeValue(font: font)
//            }
//        }
//        return attributes
//    }
//
//    func applyAttributesToSelectedRange(_ textView: TextViewOverRidden, spans: [(span: RichTextSpanInternal, shouldApply: Bool)], onCompletion: (() -> Void)? = nil) {
//        var spansToUpdate = spans.filter { $0.span.attributes?.header != nil }
//        spansToUpdate.append(contentsOf: spans.filter { $0.span.attributes?.header == nil })
//        spansToUpdate.forEach { span in
//            span.span.attributes?.styles().forEach { style in
//                textView.textStorage.setRichTextStyle(style, to: span.shouldApply, at: span.span.spanRange)
//            }
//        }
//        onCompletion?()
//    }
//}
