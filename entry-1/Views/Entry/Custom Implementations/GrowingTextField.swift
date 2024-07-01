//
//  GrowingTextFoe;d.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 6/30/24.
//
import SwiftUI
import UIKit
import Combine

/// A SwiftUI wrapper for a growing UITextView with bullet pointing and tabbing support.
struct GrowingTextField: UIViewRepresentable {
    @Binding var attributedText: NSAttributedString
    let fontName: String
    let fontSize: CGFloat
    let fontColor: UIColor
    let cursorColor: UIColor
    var backgroundColor: UIColor?
    var hasInset: Bool = true
    
    @Binding var cursorPosition: NSRange?
    @ObservedObject var viewModel: TextEditorViewModel

    /// Creates the `UITextView` with the required configurations.
    func makeUIView(context: Context) -> UITextView {
        let textStorage = NSTextStorage()
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        
        let textContainer = NSTextContainer(size: CGSize(width: 0, height: CGFloat.greatestFiniteMagnitude))
        textContainer.widthTracksTextView = true
        layoutManager.addTextContainer(textContainer)
        
        let textView = UITextView(frame: .zero, textContainer: textContainer)
        context.coordinator.textView = textView
        
        textView.backgroundColor = backgroundColor ?? .clear
        textView.tintColor = cursorColor
        textView.font = UIFont(name: fontName, size: fontSize)
        textView.textColor = fontColor
        textView.isScrollEnabled = true
        textView.showsVerticalScrollIndicator = false
        textView.delegate = context.coordinator
        textView.textContainerInset = hasInset ? UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10) : .zero
        textView.textContainer.lineFragmentPadding = 0
        
        return textView
    }
    
    /// Updates the `UITextView` when the attributed text changes.
    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.attributedText != attributedText {
            uiView.attributedText = attributedText
            if let cursorPosition = cursorPosition {
                uiView.selectedRange = cursorPosition
            }
        }
    }
    
    /// Creates the coordinator for managing the `UITextView` delegate.
    func makeCoordinator() -> Coordinator {
        Coordinator(self, viewModel: viewModel)
    }
    
    /// Coordinator for handling `UITextView` delegate methods.
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: GrowingTextField
        var viewModel: TextEditorViewModel
        var textView: UITextView?
        private var cancellables = Set<AnyCancellable>()
        
        init(_ parent: GrowingTextField, viewModel: TextEditorViewModel) {
            self.parent = parent
            self.viewModel = viewModel
            super.init()
            
            // Subscribe to text insertion updates from the view model.
            viewModel.$textToInsert
                .compactMap { $0 }
                .receive(on: DispatchQueue.main)
                .sink { [weak self] textToInsert in
                    self?.insertTextAtCursor(text: textToInsert)
                }
                .store(in: &cancellables)
        }
        
        /// Called when the text in the `UITextView` changes.
        func textViewDidChange(_ textView: UITextView) {
            self.textView = textView
            updateTextViewHeight(textView)
            if let selectedTextRange = textView.selectedTextRange {
                let cursorPosition = textView.offset(from: textView.beginningOfDocument, to: selectedTextRange.start)
                parent.cursorPosition = NSRange(location: cursorPosition, length: textView.selectedRange.length)
            } else {
                print("CURSOR POSITION: \(parent.cursorPosition)")
                parent.cursorPosition = NSRange(location: textView.text.count, length: 0)
            }
            parent.attributedText = textView.attributedText
        }
        
        /// Inserts text at the current cursor position in the `UITextView`.
        private func insertTextAtCursor(text: String) {
            guard let textView = self.textView else { return }
            
            let mutableAttributedString = NSMutableAttributedString(attributedString: textView.attributedText)
            var range = textView.selectedRange
            
            // Ensure the range is within bounds
            if range.location > mutableAttributedString.length {
                range = NSRange(location: mutableAttributedString.length, length: 0)
            }
            
            // Preserve existing attributes
            let attributes: [NSAttributedString.Key: Any]
            if range.location > 0 && range.location - 1 < mutableAttributedString.length {
                attributes = textView.attributedText.attributes(at: range.location - 1, effectiveRange: nil)
            } else {
                attributes = [
                    .font: textView.font ?? UIFont.systemFont(ofSize: UIFont.systemFontSize),
                    .foregroundColor: textView.textColor ?? .black
                ]
            }
            
            if text == "\t" {
                // Insert tab character and update cursor position
                if range.length == 0 {
                    mutableAttributedString.insert(NSAttributedString(string: "\t", attributes: attributes), at: range.location)
                    range.location += 1
                } else {
                    let selectedText = mutableAttributedString.attributedSubstring(from: range).string
                    let lines = selectedText.components(separatedBy: .newlines)
                    let indentedLines = lines.map { "\t\($0)" }
                    let updatedText = indentedLines.joined(separator: "\n")
                    mutableAttributedString.replaceCharacters(in: range, with: NSAttributedString(string: updatedText, attributes: attributes))
                    range.length = updatedText.utf16.count
                }
            } else if text == "\t• " {
                if range.length == 0 {
                    let bulletPoint = NSAttributedString(string: "\t• ", attributes: attributes)
                    mutableAttributedString.insert(bulletPoint, at: range.location)
                    range.location += bulletPoint.length
                } else {
                    // Text is selected, apply bullet point to the first line and indent the rest
                    let selectedText = mutableAttributedString.attributedSubstring(from: range).string
                    var lines = selectedText.components(separatedBy: .newlines)
                    lines[0] = "\t• " + lines[0] // Add bullet point and tab to the first line
                    for i in 1..<lines.count {
                        lines[i] = "\t" + lines[i] // Indent remaining lines
                    }
                    let updatedText = lines.joined(separator: "\n")
                    mutableAttributedString.replaceCharacters(in: range, with: NSAttributedString(string: updatedText, attributes: attributes))
                    range.length = updatedText.utf16.count
                }
            } else {
                // Insert text and update cursor position
                mutableAttributedString.replaceCharacters(in: range, with: NSAttributedString(string: text, attributes: attributes))
                range.location += text.utf16.count
                range.length = 0
            }
            
            textView.attributedText = mutableAttributedString
            textView.selectedRange = range
            parent.cursorPosition = range//the line that fixed it
            parent.attributedText = mutableAttributedString
        }
        
        /// Updates the height of the `UITextView` based on its content.
        func updateTextViewHeight(_ textView: UITextView) {
            let size = textView.sizeThatFits(CGSize(width: textView.frame.width, height: CGFloat.greatestFiniteMagnitude))
            textView.contentSize = size
        }
        
        /// Handles text changes in the `UITextView`.
        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            return true
        }
    }
}

/// ViewModel for managing text in the RichTextEditor.
class TextEditorViewModel: ObservableObject {
    @Published var text: String = ""
    @Published var textToInsert: String?
    
    /// Inserts the specified text into the editor.
    func insertText() {
        guard let textToInsert = textToInsert else { return }
        text.append(textToInsert)
        self.textToInsert = nil
    }
    
    /// Adds a bullet point to the text.
    func addBulletPoint() {
        let bulletPoint = "\t• "
        text.append("\(bulletPoint)")
    }
    
    /// Inserts a tab character into the text.
    func insertTab() {
        let tab = "\t"
        text.append(tab)
    }
}

/// Extension to convert a `Binding<String>` to `Binding<NSAttributedString>`.
extension Binding where Value == String {
    /// Converts a `Binding<String>` to `Binding<NSAttributedString>` with the specified font and color.
    func asAttributedString(fontName: String, fontSize: CGFloat, fontColor: UIColor) -> Binding<NSAttributedString> {
        Binding<NSAttributedString>(
            get: {
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont(name: fontName, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize),
                    .foregroundColor: fontColor
                ]
                return NSAttributedString(string: self.wrappedValue, attributes: attributes)
            },
            set: { newValue in
                self.wrappedValue = newValue.string
            }
        )
    }
}
