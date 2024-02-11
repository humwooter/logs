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
    let data: Data
    
    func makeUIView(context: UIViewRepresentableContext<PDFKitView>) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = PDFDocument(data: self.data)
        pdfView.autoScales = true
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: UIViewRepresentableContext<PDFKitView>) {
    }
}

struct AsyncPDFKitView: UIViewRepresentable {
    var url: URL
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true // Automatically scale the PDF to fit the view
        return pdfView
    }

//    func updateUIView(_ uiView: PDFView, context: Context) {
//        Task {
//            guard url.isFileURL else { return }
//            
//            // Asynchronously load the PDF document from the URL
//            if let data = try? Data(contentsOf: url), let pdfDocument = PDFDocument(data: data) {
//                DispatchQueue.main.async {
//                    uiView.document = pdfDocument
//                }
//            } else {
//                print("Failed to load PDF from URL: \(url)")
//            }
//        }
//    }
    
    //updated to only display the first 10 pages
    func updateUIView(_ uiView: PDFView, context: Context) {
          Task {
              guard url.isFileURL else { return }
              
              // Asynchronously load the PDF document from the URL
              if let data = try? Data(contentsOf: url), let originalDocument = PDFDocument(data: data) {
                  let newDocument = PDFDocument()
                  
                  // Copy only the first 5 pages
                  for pageIndex in 0..<min(originalDocument.pageCount, 5) {
                      if let page = originalDocument.page(at: pageIndex) {
                          newDocument.insert(page, at: newDocument.pageCount)
                      }
                  }
                  
                  DispatchQueue.main.async {
                      uiView.document = newDocument
                  }
              } else {
                  print("Failed to load PDF from URL: \(url)")
              }
          }
      }
}


struct CustomAsyncPDFThumbnailView: UIViewRepresentable {
    var pdfURL: URL
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let asyncImageView = UIImageView()
        asyncImageView.contentMode = .scaleAspectFit
        asyncImageView.backgroundColor = .black
        view.addSubview(asyncImageView)
        asyncImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            asyncImageView.topAnchor.constraint(equalTo: view.topAnchor),
            asyncImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            asyncImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            asyncImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        guard let imageView = uiView.subviews.first as? UIImageView else { return }
        
        Task {
            if let imageData = generatePNGFromPDF(url: pdfURL) {
                imageView.image = UIImage(data: imageData)
            } else {
                print("Failed to generate or load thumbnail from PDF URL: \(pdfURL)")
            }
        }
    }
}

