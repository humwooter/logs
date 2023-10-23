//
//  TextViewWithImage.swift
//  entry-1
//
//  Created by Katya Raman on 8/19/23.
//

import Foundation
import UIKit
import SwiftUI

struct TextViewWithImage: UIViewRepresentable {
    @Binding var entryContent: String
    @Binding var selectedImage: UIImage?

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = entryContent

        if let image = selectedImage {
            let textAttachment = NSTextAttachment()
            textAttachment.image = image

            let attributedString = NSMutableAttributedString(attributedString: uiView.attributedText)
            attributedString.insert(NSAttributedString(attachment: textAttachment), at: uiView.selectedRange.location)

            uiView.attributedText = attributedString

            selectedImage = nil // Reset to avoid re-insertion
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: TextViewWithImage

        init(_ parent: TextViewWithImage) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.entryContent = textView.text
        }
    }
}
