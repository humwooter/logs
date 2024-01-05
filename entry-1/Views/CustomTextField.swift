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

    

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.backgroundColor = UIColor(Color.white.opacity(0.05)) // Set background color to clear
        textView.font = UIFont(name: fontName, size: fontSize)  // Set custom font
        textView.textColor = fontColor  // Set font color
        textView.isScrollEnabled = true
        textView.showsVerticalScrollIndicator = false
        textView.delegate = context.coordinator
        textView.textContainerInset = UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)

        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
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
            parent.text = textView.text
        }
    }
}

