//
//  PDFKitView.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 2/7/24.
//

import Foundation
import PDFKit
import SwiftUI
import UIKit


struct PDFKitView: UIViewRepresentable {
    let data: Data // new variable to get the URL of the document
    
    func makeUIView(context: UIViewRepresentableContext<PDFKitView>) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = PDFDocument(data: self.data)
        pdfView.autoScales = true
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: UIViewRepresentableContext<PDFKitView>) {
    }
}
