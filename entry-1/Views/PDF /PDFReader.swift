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
import Speech

class PDFReaderViewModel: ObservableObject {
    @Published var selectedText: String? = nil
}

struct PDFKitViewFullscreen: UIViewRepresentable {
    let data: Data
    var onPageChanged: (Int) -> Void // Callback for page changes
    @ObservedObject var viewModel: PDFReaderViewModel // Add this line

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = PDFDocument(data: self.data)
        pdfView.autoScales = true
        
        // Set the display mode to single page continuous and direction to horizontal
        pdfView.displayDirection = .horizontal
        pdfView.displayMode = .singlePageContinuous
        pdfView.usePageViewController(true, withViewOptions: [UIPageViewController.OptionsKey.interPageSpacing: 20])
        pdfView.backgroundColor = .clear
        
        let tapRecognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
         pdfView.addGestureRecognizer(tapRecognizer)
           
        
        // Add observer for page changes
        NotificationCenter.default.addObserver(forName: Notification.Name.PDFViewPageChanged, object: pdfView, queue: .main) { _ in
            if let currentPage = pdfView.currentPage, let index = pdfView.document?.index(for: currentPage) {
                onPageChanged(index)
            }
        }
        
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: UIViewRepresentableContext<PDFKitViewFullscreen>) {
        
        // Here, you can add code to update the view if needed.
    }
    
    func makeCoordinator() -> Coordinator {
          Coordinator(self, viewModel: viewModel)
      }
      
      class Coordinator: NSObject {
          var parent: PDFKitViewFullscreen
          var viewModel: PDFReaderViewModel
          
          init(_ parent: PDFKitViewFullscreen, viewModel: PDFReaderViewModel) {
              self.parent = parent
              self.viewModel = viewModel
          }
        
          
          @objc func handleTap(_ sender: UITapGestureRecognizer) {
              print("Tap recognized")
              guard let pdfView = sender.view as? PDFView else { return }
              if let selection = pdfView.currentSelection?.string {
                  print("Selected text: \(selection)")
                  viewModel.selectedText = selection
              } else {
                  print("No selection found")
              }
          }
      }
}



struct PDFReader: View {
    @EnvironmentObject var userPreferences: UserPreferences
    @ObservedObject var entry: Entry
    @Binding var isFullScreen: Bool
    @State private var currentPageIndex: Int = 0 // Track the current page index
    @StateObject private var viewModel = PDFReaderViewModel() // Instantiate the view model

    
    // Speech synthesizer for narrating PDF text
    private let speechSynthesizer = AVSpeechSynthesizer()
    
    var body: some View {
        NavigationView {

            VStack {
                if let filename = entry.mediaFilename, let data = loadPDFData(filename: filename), isPDF(data: data) {
                    PDFKitViewFullscreen(data: data, onPageChanged: { pageIndex in
                        self.currentPageIndex = pageIndex
                    }, viewModel: viewModel)
                    .navigationTitle("PDF Reader")

                    .onDisappear {
                        self.speechSynthesizer.stopSpeaking(at: .immediate)
                    }
                    
                    buttonBar(data: data)

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
            .onAppear {
                for voice in AVSpeechSynthesisVoice.speechVoices() {
                    print("Language: \(voice.language), Name: \(voice.name), Identifier: \(voice.identifier)")
                }
            }
        }
    }
    

    func narratePDF(data: Data, pageIndex: Int, selectedText: String? = nil) {
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }

        let textToNarrate: String
        
        if let selectedText = selectedText, !selectedText.isEmpty {
            // Use the provided selected text
            textToNarrate = selectedText
        } else if let document = PDFDocument(data: data), let page = document.page(at: pageIndex) {
            // Fallback to narrating the entire page's text
            textToNarrate = page.string ?? ""
        } else {
            // Handle cases where there is no text to narrate
            return
        }
        
        let utterance = AVSpeechUtterance(string: textToNarrate)
        
        if let voice = AVSpeechSynthesisVoice(identifier: "com.apple.voice.compact.en-AU.Karen") {
            utterance.voice = voice
        }
        
        utterance.pitchMultiplier = 0.9
        utterance.preUtteranceDelay = 0.1
        utterance.preUtteranceDelay = 0.1

//        utterance.volume = 1.0
        speechSynthesizer.speak(utterance)
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
    
    
    @ViewBuilder
    func buttonBar(data: Data) -> some View {
        HStack(spacing: 35) {
            Spacer()
            Button {
                narratePDF(data: data, pageIndex: currentPageIndex, selectedText: viewModel.selectedText)

            } label: {
                Label("Narrate page", systemImage: "speaker.wave.3.fill")
            }
            
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 20)
        .background(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color(UIColor.label))).opacity(0.05))
        .foregroundColor(userPreferences.accentColor)
//        .background(Color(UIColor.label).opacity(0.05))

    }
}
