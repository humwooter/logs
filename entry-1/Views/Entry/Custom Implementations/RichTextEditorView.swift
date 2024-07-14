//
//  RichTextEditorView.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 7/12/24.
//

import SwiftUI

struct RichTextEditorView: UIViewRepresentable {
    @Binding var htmlText: String
    @Binding var dynamicHeight: CGFloat

    class Coordinator: NSObject, RichTextEditorDelegate {
        func heightDidChange() {
            
        }
        
        var parent: RichTextEditorView

        init(_ parent: RichTextEditorView) {
            self.parent = parent
        }

        func textDidChange(text: String) {
            parent.htmlText = text
        }

        func heightDidChange(newHeight: CGFloat) {
            parent.dynamicHeight = newHeight
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    func makeUIView(context: Context) -> RichTextEditor {
        let editor = RichTextEditor()
        editor.delegate = context.coordinator
        editor.text = htmlText

        return editor
    }

    func updateUIView(_ editor: RichTextEditor, context: Context) {}
}
