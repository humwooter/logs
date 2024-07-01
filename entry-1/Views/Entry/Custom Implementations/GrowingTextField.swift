//
//  GrowingTextFoe;d.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 6/30/24.
//

import SwiftUI
import UIKit
import Combine

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

    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.attributedText != attributedText {
            uiView.attributedText = attributedText
            if let cursorPosition = cursorPosition {
                uiView.selectedRange = cursorPosition
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self, viewModel: viewModel)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: GrowingTextField
        var viewModel: TextEditorViewModel
        var textView: UITextView?
        private var cancellables = Set<AnyCancellable>()
        
        init(_ parent: GrowingTextField, viewModel: TextEditorViewModel) {
            self.parent = parent
            self.viewModel = viewModel
            super.init()
            
            viewModel.$textToInsert
                .compactMap { $0 }
                .receive(on: DispatchQueue.main)
                .sink { [weak self] textToInsert in
                    self?.insertTextAtCursor(text: textToInsert)
                }
                .store(in: &cancellables)
        }
        
        func textViewDidChange(_ textView: UITextView) {
               parent.attributedText = textView.attributedText
               self.textView = textView
               updateTextViewHeight(textView)
               if let cursorPosition = textView.selectedTextRange {
                   let position = textView.offset(from: textView.beginningOfDocument, to: cursorPosition.start)
                   parent.cursorPosition = NSRange(location: position, length: 0)
               }
           }

           private func insertTextAtCursor(text: String) {
               print("entered insertTextAtCursor from inside the Coordinator class with text: \(text)")
               guard let textView = self.textView else { return }

               let mutableAttributedString = NSMutableAttributedString(attributedString: textView.attributedText)
               var range = textView.selectedRange

               // Preserve existing attributes
               let attributes: [NSAttributedString.Key: Any]
               if range.location > 0 {
                   attributes = textView.attributedText.attributes(at: range.location - 1, effectiveRange: nil)
               } else {
                   attributes = [
                       .font: textView.font ?? UIFont.systemFont(ofSize: UIFont.systemFontSize),
                       .foregroundColor: textView.textColor ?? .black
                   ]
               }

               if text == "\t" {
                   if range.length == 0 {
                       let updatedText = NSMutableAttributedString(attributedString: mutableAttributedString)
                       updatedText.insert(NSAttributedString(string: text, attributes: attributes), at: range.location)
                       textView.attributedText = updatedText
                       range.location += text.utf16.count
                       textView.selectedRange = range
                   } else {
                       let selectedText = mutableAttributedString.attributedSubstring(from: range)
                       let lines = selectedText.string.components(separatedBy: .newlines)
                       let indentedLines = lines.map { "\t\($0)" }
                       let updatedText = indentedLines.joined(separator: "\n")
                       mutableAttributedString.replaceCharacters(in: range, with: NSAttributedString(string: updatedText, attributes: attributes))
                       textView.attributedText = mutableAttributedString
                       range.length = updatedText.utf16.count
                   }
               } else if text == "\t• " {
                   if range.length == 0 {
                       let lineStart = mutableAttributedString.mutableString.lineRange(for: NSRange(location: range.location, length: 0)).location
                       mutableAttributedString.insert(NSAttributedString(string: text, attributes: attributes), at: lineStart)
                       textView.attributedText = mutableAttributedString
                       range.location += text.utf16.count
                   } else {
                       let selectedText = mutableAttributedString.attributedSubstring(from: range)
                       var lines = selectedText.string.components(separatedBy: .newlines)
                       lines[0] = "\t• " + lines[0]
                       for i in 1..<lines.count {
                           lines[i] = "\t" + lines[i]
                       }
                       let updatedText = lines.joined(separator: "\n")
                       mutableAttributedString.replaceCharacters(in: range, with: NSAttributedString(string: updatedText, attributes: attributes))
                       range.length = updatedText.utf16.count
                   }
               } else {
                   mutableAttributedString.replaceCharacters(in: range, with: NSAttributedString(string: text, attributes: attributes))
                   range.location += text.utf16.count
                   range.length = 0
               }

               textView.selectedRange = range
               self.parent.attributedText = mutableAttributedString
           }



        func updateTextViewHeight(_ textView: UITextView) {
            let size = textView.sizeThatFits(CGSize(width: textView.frame.width, height: CGFloat.greatestFiniteMagnitude))
            textView.contentSize = size
        }
    }
}

class TextEditorViewModel: ObservableObject {
    @Published var textToInsert: String?
}


// Extension to convert a Binding<String> to Binding<NSAttributedString> with specified attributes
extension Binding where Value == String {
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

