//
//  CustomTextField.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 1/4/24.
//

import SwiftUI
import UIKit
import Combine

struct GrowingTextField: UIViewRepresentable {
    @Binding var text: String
    let fontName: String
    let fontSize: CGFloat
    let fontColor: UIColor
    let cursorColor: UIColor
    var backgroundColor: UIColor?
    var initialText: String?
    
    @Binding var cursorPosition: NSRange?
    @ObservedObject var viewModel: TextEditorViewModel
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        context.coordinator.textView = textView
        if let backgroundColor {
            textView.backgroundColor = backgroundColor
        } else {
//            textView.backgroundColor = UIColor(Color(fontColor).opacity(0.05))
            textView.backgroundColor = UIColor.clear

        }
        textView.tintColor = cursorColor
        
//        for familyName in UIFont.familyNames {
//            print("\n-- \(familyName) --")
//            for fontName in UIFont.fontNames(forFamilyName: familyName) {
//                print(fontName)
//            }
//        }
//
//        print("FONT NAME: \(fontName)")
//        print("FONT SIZE: \(fontSize)")

        textView.font = UIFont(name: fontName, size: fontSize)  // Set custom font
        textView.textColor = fontColor  // Set font color
        textView.isScrollEnabled = true
        textView.showsVerticalScrollIndicator = false
        textView.delegate = context.coordinator
        textView.textContainerInset = UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
        
        print("makeUIView called for GrowingTextField")
        

        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        print("updateUIView called for GrowingTextField with text: \(text)")
        if uiView.text != text {
            uiView.text = text
        }
    }
    
    func makeCoordinator() -> Coordinator {
        print("makeCoordinator called for GrowingTextField")
        return Coordinator(self, viewModel: viewModel)
        
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: GrowingTextField
        var viewModel: TextEditorViewModel
        var textView: UITextView?
        private var cancellables = Set<AnyCancellable>() // To hold the subscription
        
        init(_ parent: GrowingTextField, viewModel: TextEditorViewModel) {
            self.parent = parent
            self.viewModel = viewModel
            super.init()
            
            // Observe changes to textToInsert
            viewModel.$textToInsert
                .compactMap { $0 } // Filter out nil values
                .receive(on: DispatchQueue.main) // Ensure UI updates are on the main thread
                .sink { [weak self] textToInsert in
                    self?.insertTextAtCursor(text: textToInsert)
                }
                .store(in: &cancellables)
        }
        
        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
            self.textView = textView // Keep a reference to the textView
        }
        
        //
//                private func insertTextAtCursor(text: String) {
//                    print("entered insertTextAtCursor from inside the Coordinator class with text: \(text)")
//        //            DispatchQueue.main.async {
//                        guard let textView = self.textView else { return }
//        
//                        let currentText = textView.text as NSString
//                        var range = textView.selectedRange
//                        let updatedText = currentText.replacingCharacters(in: range, with: text)
//        
//                        // Update the text directly to prevent cursor jump
//                        textView.text = updatedText as String
//        
//                        // Adjust range location to account for new text insertion
//                        range.location += text.utf16.count
//                        range.length = 0
//        
//                        // Restore cursor position
//                        textView.selectedRange = range
//        
//                        // Update the parent view's text to keep it in sync
//                        self.parent.text = updatedText as String
//        //            }
//                }
        
 
        
        private func insertTextAtCursor(text: String) {
            print("entered insertTextAtCursor from inside the Coordinator class with text: \(text)")
            guard let textView = self.textView else { return }
            
            let currentText = textView.text as NSString
            var range = textView.selectedRange
            
            print("RANGE LENGTH: \(range.length)")
            print("RANGE UPPER BOUND: \(range.upperBound)")
            print("RANGE LOWER BOUND: \(range.lowerBound)")
            
            // Check if the text is neither a tab for indentation nor a bullet point with a tab, and there is no highlighted text
            if range.length == 0 {
                // Use the logic from the previous function for simple text insertion
                let updatedText = currentText.replacingCharacters(in: range, with: text)
                textView.text = updatedText as String
                range.location += text.utf16.count
                range.length = 0
                textView.selectedRange = range
                self.parent.text = updatedText as String
            } else {
                // Special handling for tabs and bullet points, or if there is highlighted text
                if text == "\t" {
                    let selectedText = currentText.substring(with: range)
                    let lines = selectedText.components(separatedBy: .newlines)
                    let indentedLines = lines.map { "\t\($0)" }
                    let updatedText = indentedLines.joined(separator: "\n")
                    textView.text = currentText.replacingCharacters(in: range, with: updatedText)
                    range.length = updatedText.utf16.count
                } else if text == "\t• " {
                    if range.length == 0 { // No text is selected, apply bullet point to the current line
                        let lineStart = currentText.lineRange(for: NSRange(location: range.location, length: 0)).location
                        let updatedText = currentText.replacingCharacters(in: NSRange(location: lineStart, length: 0), with: "\t• ")
                        textView.text = updatedText as String
                        range.location += 3 // Move cursor after the bullet point and tab
                    } else { // Text is selected, apply bullet point to the first line and indent the rest
                        let selectedText = currentText.substring(with: range)
                        var lines = selectedText.components(separatedBy: .newlines)
                        lines[0] = "\t• " + lines[0] // Add bullet point and tab to the first line
                        for i in 1..<lines.count {
                            lines[i] = "\t" + lines[i] // Indent remaining lines
                        }
                        let updatedText = lines.joined(separator: "\n")
                        textView.text = currentText.replacingCharacters(in: range, with: updatedText)
                        range.length = updatedText.utf16.count
                    }
                } else {
                    // For other types of text when there is highlighted text
                    let updatedText = currentText.replacingCharacters(in: range, with: text)
                    textView.text = updatedText as String
                    range.location += text.utf16.count
                    range.length = 0
                }
                
                textView.selectedRange = range
                self.parent.text = textView.text
            }
        }

        
//        private func insertTextAtCursor(text: String) {
//            print("entered insertTextAtCursor from inside the Coordinator class with text: \(text)")
//            guard let textView = self.textView else { return }
//            
//            let currentText = textView.text as NSString
//            var range = textView.selectedRange
//            
//            print("RANGE LENGTH: \(range.length)")
//            print("RANGE UPPER BOUND: \(range.upperBound)")
//            print("RANGE LOWER BOUND: \(range.lowerBound)")
//
//            
//            if text == "\t" { // Handle tab for indentation
//                let selectedText = currentText.substring(with: range)
//                let lines = selectedText.components(separatedBy: .newlines)
//                let indentedLines = lines.map { "\t\($0)" }
//                let updatedText = indentedLines.joined(separator: "\n")
//                textView.text = currentText.replacingCharacters(in: range, with: updatedText)
//                range.length = updatedText.utf16.count
//            } else if text == "\t• " { // Handle bullet point followed by a tab
//                if range.length == 0 { // No text is selected, apply bullet point to the current line
//                    let lineStart = currentText.lineRange(for: NSRange(location: range.location, length: 0)).location
//                    let updatedText = currentText.replacingCharacters(in: NSRange(location: lineStart, length: 0), with: "\t• ")
//                    textView.text = updatedText as String
//                    range.location += 3 // Move cursor after the bullet point and tab
//                } else { // Text is selected, apply bullet point to the first line and indent the rest
//                    let selectedText = currentText.substring(with: range)
//                    var lines = selectedText.components(separatedBy: .newlines)
//                    lines[0] = "\t• " + lines[0] // Add bullet point and tab to the first line
//                    for i in 1..<lines.count {
//                        lines[i] = "\t" + lines[i] // Indent remaining lines
//                    }
//                    let updatedText = lines.joined(separator: "\n")
//                    textView.text = currentText.replacingCharacters(in: range, with: updatedText)
//                    range.length = updatedText.utf16.count
//                }
//            } else {
//                // For non-special text, insert it as before
//                let updatedText = currentText.replacingCharacters(in: range, with: text)
//                textView.text = updatedText as String
//                range.location += text.utf16.count
//                range.length = 0
//            }
//            
//            textView.selectedRange = range
//            self.parent.text = textView.text
//        }
    }
}


    class TextEditorViewModel: ObservableObject {
        // Use this to trigger text insertions from SwiftUI.
        @Published var textToInsert: String?
    }
