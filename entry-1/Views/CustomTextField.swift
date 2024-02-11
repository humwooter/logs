//
//  CustomTextField.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 1/4/24.
//

import SwiftUI
import UIKit

struct GrowingTextField: UIViewRepresentable {
    @Binding var text: String
    let fontName: String
    let fontSize: CGFloat
    let fontColor: UIColor
    var initialText: String?
    @Binding var cursorPosition: NSRange? // Add this

    

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()

        textView.backgroundColor = UIColor(Color(fontColor).opacity(0.05))

        textView.font = UIFont(name: fontName, size: fontSize)  // Set custom font
        textView.textColor = fontColor  // Set font color
        textView.isScrollEnabled = true
        textView.showsVerticalScrollIndicator = false
        textView.delegate = context.coordinator
        textView.textContainerInset = UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
        textView.dataDetectorTypes = .link  // Enable detection of links

        return textView
    }
    

//    
//    func updateUIView(_ uiView: UITextView, context: Context) {
//        if uiView.text != text {
//            uiView.text = text
//        }
//    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text // Set the text
        uiView.textColor = fontColor // Update the font color if needed

        // Set the cursor position if defined
        if let cursorPosition = cursorPosition, !uiView.text.isEmpty {
            if let startPosition = uiView.position(from: uiView.beginningOfDocument, offset: cursorPosition.location) {
                if let endPosition = uiView.position(from: startPosition, offset: cursorPosition.length) {
                    uiView.selectedTextRange = uiView.textRange(from: startPosition, to: endPosition)

                }
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: GrowingTextField

        init(_ parent: GrowingTextField) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            // This will capture the updated text and cursor position
            parent.text = textView.text // Update the bound text
            let cursorPosition = textView.selectedRange
            parent.cursorPosition = cursorPosition // Update the cursor position
        }

        func insertTextAtCursor(_ textView: UITextView, text: String) {
               if let selectedRange = textView.selectedTextRange {
                   textView.replace(selectedRange, withText: text)
                   parent.text = textView.text // Update the bound text
               }
           }
        
//        func textViewDidChangeSelection(_ textView: UITextView) {
//            if let selectedRange = textView.selectedTextRange {
//                let location = textView.offset(from: textView.beginningOfDocument, to: selectedRange.start)
//                let length = textView.offset(from: selectedRange.start, to: selectedRange.end)
//                parent.cursorPosition = NSRange(location: location, length: length)
//            }
//        }
        
        func textViewDidChangeSelection(_ textView: UITextView) {
            // This will capture the new cursor position when the selection changes
            let cursorPosition = textView.selectedRange
            parent.cursorPosition = cursorPosition // Update the cursor position
        }

        
        
    }
}

