//
//  PDFReader.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 2/10/24.
//

import Foundation
import SwiftUI
import UIKit
import PDFKit


struct PDFKitViewFullscreen: UIViewRepresentable {
    let data: Data
    
    func makeUIView(context: UIViewRepresentableContext<PDFKitViewFullscreen>) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = PDFDocument(data: self.data)
        pdfView.autoScales = true
        
        // Set the display mode to single page continuous and direction to horizontal
        pdfView.displayDirection = .horizontal
        pdfView.displayMode = .singlePageContinuous
        pdfView.usePageViewController(true, withViewOptions: [UIPageViewController.OptionsKey.interPageSpacing: 20])
        pdfView.backgroundColor = .clear

        
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: UIViewRepresentableContext<PDFKitViewFullscreen>) {
        // Here, you can add code to update the view if needed.
    }
}


struct PDFReader: View {
    @EnvironmentObject var userPreferences: UserPreferences // Your user preferences object
    @ObservedObject var entry: Entry // The entry containing the PDF filename
    @Binding var isFullScreen: Bool // Binding to control the sheet presentation

    var body: some View {
        NavigationView {
            VStack {
                if let filename = entry.mediaFilename, let data = loadPDFData(filename: filename), isPDF(data: data) {
                    PDFKitViewFullscreen(data: data)
                        .navigationTitle("PDF Reader")
                        .navigationBarTitleDisplayMode(.inline)
                } else {
                    Text("Unable to load PDF.")
                }
            }
            .background {
                ZStack {
                    Color(UIColor.systemGroupedBackground)
                    LinearGradient(colors: [userPreferences.backgroundColors[0], userPreferences.backgroundColors.count > 1 ? userPreferences.backgroundColors[1] : userPreferences.backgroundColors[0]], startPoint: .top, endPoint: .bottom)
                        .ignoresSafeArea()
                }
            }
        }
    }

    func loadPDFData(filename: String) -> Data? {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        return try? Data(contentsOf: fileURL)
    }

    func isPDF(data: Data) -> Bool {
        // Implement your logic to verify if the data represents a PDF
        return true
    }
}
