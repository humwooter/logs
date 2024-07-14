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
    @Binding var currentPageIndex: Int16 // Changed to a binding
    @EnvironmentObject var coreDataManager: CoreDataManager

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = PDFDocument(data: self.data)
        pdfView.autoScales = true
        
        // Set the display mode to single page continuous and direction to horizontal
        pdfView.displayDirection = .vertical
        pdfView.displayMode = .singlePageContinuous
        pdfView.usePageViewController(true, withViewOptions: [UIPageViewController.OptionsKey.interPageSpacing: 20])
        pdfView.backgroundColor = .clear
        
        let tapRecognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
         pdfView.addGestureRecognizer(tapRecognizer)
           
        
        // Add observer for page changes
        NotificationCenter.default.addObserver(forName: Notification.Name.PDFViewPageChanged, object: pdfView, queue: .main) { _ in
            if let currentPage = pdfView.currentPage, let index = pdfView.document?.index(for: currentPage) {
//                DispatchQueue.main.async {
                    self.currentPageIndex = Int16(index)
//                    
//                    do {
//                        try coreDataManager.viewContext.save()
//                    } catch {
//                        // Handle the error, e.g., log it or show an alert to the user
//                        print("Failed to save context after updating entry content: \(error)")
//                    }
//                }
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
    @EnvironmentObject var coreDataManager: CoreDataManager
    @ObservedObject var entry: Entry
    @Binding var isFullScreen: Bool
//    @State private var currentPageIndex: Int = 0 // Track the current page index
    @StateObject private var viewModel = PDFReaderViewModel() // Instantiate the view model
    @Binding var currentPageIndex: Int16 // Changed to a binding

    // Speech synthesizer for narrating PDF text
    private let speechSynthesizer = AVSpeechSynthesizer()
    @State private var showTextField_PDF = false

    @ObservedObject var textEditorViewModel = TextEditorViewModel()
    @State private var cursorPosition: NSRange? = nil
    @State private var entryContent: String = ""
    @State private var prevEntryContent: String = ""
    @Environment(\.presentationMode) private var presentationMode

    @State private var speechRate: Float = AVSpeechUtteranceDefaultSpeechRate
    @State private var isNarrating = false

    var body: some View {
        NavigationView {
          
                VStack {
                    HStack {
                        
                        if showTextField_PDF {
                            Button {
                                    entry.content = prevEntryContent
                                    do {
                                        try coreDataManager.viewContext.save()
                                    } catch {
                                        // Handle the error, e.g., log it or show an alert to the user
                                        print("Failed to save context after updating entry content: \(error)")
                                    }
                                showTextField_PDF = false
                            } label: {
                                        Image(systemName: "arrow.left")
                                            .foregroundStyle(userPreferences.accentColor)
                                            .padding(.horizontal)
                               
                                }
                            
                        }
                        Spacer()

                    Button {
                        if (showTextField_PDF) {
                            entry.content = entryContent
                            do {
                                try coreDataManager.viewContext.save()
                            } catch {
                                // Handle the error, e.g., log it or show an alert to the user
                                print("Failed to save context after updating entry content: \(error)")
                            }
                        }
                        showTextField_PDF.toggle()
                    } label: {
                            Image(systemName: showTextField_PDF ? "checkmark" : "pencil")
                                .foregroundStyle(showTextField_PDF ? Color.oppositeColor(of: userPreferences.accentColor) : userPreferences.accentColor)
                                .padding(.horizontal)
                        }
                        
                        
                      
                    }

                    if showTextField_PDF{
//                        GrowingTextField(
//                            attributedText: $entryContent.asAttributedString(
//                                fontName: userPreferences.fontName,
//                                fontSize: userPreferences.fontSize,
//                                fontColor: UIColor(
//                                    UIColor.foregroundColor(
//                                        background: UIColor(userPreferences.backgroundColors.first ?? Color.clear)
//                                    )
//                                )
//                            ),
//                            fontName: Binding(
//                                     get: { userPreferences.fontName },
//                                     set: { userPreferences.fontName = $0 }
//                                 ),
//                                 fontSize: Binding(
//                                     get: { CGFloat(userPreferences.fontSize) },
//                                     set: { userPreferences.fontSize = Double($0) }
//                                 ),
//                                 fontColor: Binding(
//                                     get: {
//                                         UIColor(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color(UIColor.label))))
//                                     },
//                                     set: { _ in }
//                                 ),
//                                 cursorColor: Binding(
//                                     get: { UIColor(userPreferences.accentColor) },
//                                     set: { _ in }
//                                 ),
//                                 backgroundColor: Binding(
//                                     get: { UIColor(userPreferences.backgroundColors.first ?? .clear) },
//                                     set: { _ in }
//                                 ),
//                                 enableLinkDetection: Binding(
//                                     get: { userPreferences.showLinks },
//                                     set: { userPreferences.showLinks = $0 }
//                                 ),
//                                 cursorPosition: $cursorPosition,
//                                 viewModel: textEditorViewModel
//                             )
//                        .frame(maxWidth: .infinity)
//                            .cornerRadius(15)
//                            .padding()
                        
                    }
                    
                    if let filename = entry.mediaFilename, let data = loadPDFData(filename: filename), isPDF(data: data) {
                        PDFKitViewFullscreen(data: data, onPageChanged: { pageIndex in
                            self.currentPageIndex = Int16(pageIndex)
                        }, viewModel: viewModel, currentPageIndex: $currentPageIndex)
                        .environmentObject(coreDataManager)
                        .navigationTitle("PDF Reader")
                        .frame(maxWidth: .infinity)
                        
                        .onDisappear {
                            self.speechSynthesizer.stopSpeaking(at: .immediate)
                        }
                        
                        if (showTextField_PDF) {
//                            textFormattingButtonBar()
//                                .padding(.horizontal)
                        }
//                        buttonBar(data: data)
                        
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
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 15))
                            .foregroundStyle(userPreferences.accentColor)
                    }
                }
            }
            .onAppear {
                entryContent = entry.content
                prevEntryContent = entry.content
                for voice in AVSpeechSynthesisVoice.speechVoices() {
                    print("Language: \(voice.language), Name: \(voice.name), Identifier: \(voice.identifier)")
                }
            }
        }
 
    }
    

    func narratePDF(data: Data, pageIndex: Int, selectedText: String? = nil) {
        speechSynthesizer.stopSpeaking(at: .immediate)
        if speechSynthesizer.isSpeaking {
            isNarrating = false
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
        
        if let voice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.Tessa-compact") {
            utterance.voice = voice
        }
//        if let voice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.Tessa-compact") {
//            utterance.voice = voice
//        }
        
//        utterance.pitchMultiplier = 0.9
        utterance.preUtteranceDelay = 0.1
        utterance.preUtteranceDelay = 0.1
        utterance.rate = speechRate

//        utterance.volume = 1.0
        speechSynthesizer.speak(utterance)
        isNarrating = true
    }
    
    func loadPDFData(filename: String) -> Data? {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        return try? Data(contentsOf: fileURL)
    }

    
    
    @ViewBuilder
    func buttonBar(data: Data) -> some View {
        HStack(spacing: 35) {
            Spacer()
            Button {
                narratePDF(data: data, pageIndex: Int(currentPageIndex), selectedText: viewModel.selectedText)

            } label: {
                Label("Narrate page", systemImage: "speaker.wave.3.fill")
                    .accentColor(isNarrating ? Color.oppositeColor(of: userPreferences.accentColor) : userPreferences.accentColor)
            }
            
            Slider(value: $speechRate, in: AVSpeechUtteranceMinimumSpeechRate...AVSpeechUtteranceMaximumSpeechRate)
                .accentColor(userPreferences.accentColor)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 20)
        .background(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color(UIColor.label))).opacity(0.05))
        .foregroundColor(userPreferences.accentColor)
    }
    
//    @ViewBuilder
//    func textFormattingButtonBar() -> some View {
//        HStack(spacing: 35) {
//            // Bullet Point Button
//            Button(action: {
//                // Signal to insert a bullet point at the current cursor position.
//                // Update the viewModel's textToInsert property, which triggers the insertion.
//                self.textEditorViewModel.textToInsert = "\t• "
//            }) {
//                Image(systemName: "list.bullet")
//                    .font(.system(size: 20))
//                    .foregroundColor(userPreferences.accentColor)
//            }
//
//            // Tab Button
//            Button(action: {
//                // Signal to insert a tab character.
//                self.textEditorViewModel.textToInsert = "\t"
//            }) {
//                Image(systemName: "arrow.forward.to.line")
//                    .font(.system(size: 20))
//                    .foregroundColor(userPreferences.accentColor)
//            }
//
//            // New Line Button
//            Button(action: {
//                // Signal to insert a new line.
//                self.textEditorViewModel.textToInsert = "\n"
//            }) {
//                Image(systemName: "return")
//                    .font(.system(size: 20))
//                    .foregroundColor(userPreferences.accentColor)
//            }
//
//            Spacer()
//        }
//        .padding(.vertical, 10)
//        .padding(.horizontal)
//        .background(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color(UIColor.label))).opacity(0.05))
//        .cornerRadius(15)
//    }
}
