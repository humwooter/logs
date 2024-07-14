//
//  TextViewWrapper.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 7/11/24.
//
//
//  TextViewWrapper.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 7/11/24.
//
import SwiftUI
import UIKit
//
//internal struct TextViewWrapper: UIViewRepresentable {
//    @ObservedObject var state: TextEditorViewModel
//
//    @Binding var attributedText: NSAttributedString
//    @Binding var typingAttributes: [NSAttributedString.Key: Any]
//    @Binding var attributesToApply: ((spans: [(span: RichTextSpanInternal, shouldApply: Bool)], onCompletion: () -> Void))?
//
//    private let isEditable: Bool
//    private let isUserInteractionEnabled: Bool
//    private let isScrollEnabled: Bool
//    private let linelimit: Int?
//    private let fontStyle: UIFont?
//    private let fontColor: Color
//    private let backGroundColor: UIColor
//    private let tag: Int?
//    private let onTextViewEvent: ((TextViewEvents) -> Void)?
//    private let hasInset: Bool
//    private let fontName: String
//    private let fontSize: CGFloat
//
//    public init(state: TextEditorViewModel,
//                attributedText: Binding<NSAttributedString>,
//                typingAttributes: Binding<[NSAttributedString.Key: Any]>,
//                attributesToApply: Binding<(spans: [(span: RichTextSpanInternal, shouldApply: Bool)], onCompletion: () -> Void)?>,
//                isEditable: Bool = true,
//                isUserInteractionEnabled: Bool = true,
//                isScrollEnabled: Bool = false,
//                linelimit: Int? = nil,
//                fontStyle: UIFont? = nil,
//                fontColor: Color = .black,
//                backGroundColor: UIColor = .clear,
//                tag: Int? = nil,
//                onTextViewEvent: ((TextViewEvents) -> Void)?,
//                hasInset: Bool = true,
//                fontName: String = "System",
//                fontSize: CGFloat = 14) {
//        self._state = ObservedObject(wrappedValue: state)
//        self._attributedText = attributedText
//        self._typingAttributes = typingAttributes
//        self._attributesToApply = attributesToApply
//        self.isEditable = isEditable
//        self.isUserInteractionEnabled = isUserInteractionEnabled
//        self.isScrollEnabled = isScrollEnabled
//        self.linelimit = linelimit
//        self.fontStyle = fontStyle
//        self.fontColor = fontColor
//        self.backGroundColor = backGroundColor
//        self.tag = tag
//        self.onTextViewEvent = onTextViewEvent
//        self.hasInset = hasInset
//        self.fontName = fontName
//        self.fontSize = fontSize
//    }
//
//    public func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//
//    public func makeUIView(context: Context) -> TextViewOverRidden {
//        let textView = TextViewOverRidden()
//        configureTextView(textView, context: context)
//        return textView
//    }
//
//    public func updateUIView(_ textView: TextViewOverRidden, context: Context) {
//        // Update text color and typing attributes
//        textView.textColor = UIColor(fontColor)
//        textView.typingAttributes = typingAttributes
//
//        // Apply any pending attribute changes
//        if let data = attributesToApply {
//            applyAttributesToSelectedRange(textView, spans: data.spans, onCompletion: data.onCompletion)
//        }
//
//        // Update the attributed text if it has changed
//        if textView.attributedText != attributedText {
//            let selectedRange = textView.selectedRange
//            textView.attributedText = attributedText
//            textView.selectedRange = selectedRange
//        }
//
//        // Update the selection if it has changed in the state
//        if textView.selectedRange != state.selectedRange {
//            textView.selectedRange = state.selectedRange
//        }
//
//        textView.reloadInputViews()
//    }
//
//    private func configureTextView(_ textView: TextViewOverRidden, context: Context) {
//        textView.delegate = context.coordinator
//        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
//        textView.isScrollEnabled = isScrollEnabled
//        textView.isEditable = isEditable
//        textView.isUserInteractionEnabled = isUserInteractionEnabled
//        textView.backgroundColor = backGroundColor
//        textView.textColor = UIColor(fontColor)
//        textView.textContainer.lineFragmentPadding = 0
//        textView.showsVerticalScrollIndicator = false
//        textView.showsHorizontalScrollIndicator = false
//        textView.isSelectable = true
//        textView.textContainerInset = hasInset ? UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10) : .zero
//
//        let font = UIFont(name: fontName, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
//        textView.typingAttributes = [.font: font, .foregroundColor: UIColor(fontColor)]
//        let string = NSMutableAttributedString(string: state.attributedText.string, attributes: [.font: font, .foregroundColor: UIColor(fontColor)])
//        textView.attributedText = string
//
//        if let tag = tag {
//            textView.tag = tag
//        }
//
//        if let linelimit = linelimit {
//            textView.textContainer.maximumNumberOfLines = linelimit
//        }
//    }
//
//    internal func applyAttributesToSelectedRange(_ textView: TextViewOverRidden, spans: [(span: RichTextSpanInternal, shouldApply: Bool)], onCompletion: (() -> Void)? = nil) {
//        var spansToUpdate = spans.filter { $0.span.attributes?.header != nil }
//        spansToUpdate.append(contentsOf: spans.filter { $0.span.attributes?.header == nil })
//        spansToUpdate.forEach { span in
//            span.span.attributes?.styles().forEach { style in
//                textView.textStorage.setRichTextStyle(style, to: span.shouldApply, at: span.span.spanRange)
//            }
//        }
//        onCompletion?()
//    }
//
//    internal class Coordinator: NSObject, UITextViewDelegate {
//        var parent: TextViewWrapper
//
//        init(_ uiTextView: TextViewWrapper) {
//            self.parent = uiTextView
//        }
//
//        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//            return true
//        }
//
////        func textViewDidChangeSelection(_ textView: UITextView) {
////            // Update the selection range without async to avoid lag
////            self.parent.state.selectedRange = textView.selectedRange
////            self.parent.onTextViewEvent?(.didChangeSelection(textView))
////        }
//
//        func textViewDidChangeSelection(_ textView: UITextView) {
//            parent.attributedText = textView.attributedText ?? NSAttributedString(string: textView.text ?? "")
//            // Check if the selected range has actually changed to avoid unnecessary updates
////            if self.parent.state.selectedRange != textView.selectedRange {
////                self.parent.state.selectedRange = textView.selectedRange
//////                self.parent.onTextViewEvent?(.didChangeSelection(textView))
////            }
//        }
//
//        func textViewDidBeginEditing(_ textView: UITextView) {
//            parent.onTextViewEvent?(.didBeginEditing(textView))
//        }
//
//        func textViewDidEndEditing(_ textView: UITextView) {
//            parent.onTextViewEvent?(.didEndEditing(textView))
//        }
//    }
//}
//
//// MARK: - TextViewOverRidden
//
//class TextViewOverRidden: UITextView {
//    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
//        return false // Disable clipboard menu on text selection
//    }
//}
//
//// MARK: - TextView Events
//
//public enum TextViewEvents {
//    case didChangeSelection(_ textView: UITextView)
//    case didBeginEditing(_ textView: UITextView)
//    case didChange(_ textView: UITextView)
//    case didEndEditing(_ textView: UITextView)
//}
//
//// MARK: - NSTextStorage Extension
//
//extension NSTextStorage {
//    func setRichTextStyle(_ style: RichTextStyle, to shouldApply: Bool, at range: NSRange) {
//        if shouldApply {
//            addAttribute(style.attributedStringKey, value: style.defaultAttributeValue(), range: range)
//        } else {
//            removeAttribute(style.attributedStringKey, range: range)
//        }
//    }
//}
