//
//  GrowingTextFoe;d.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 6/30/24.
//
//import SwiftUI
//import UIKit
//import Combine
//
///// A SwiftUI wrapper for a growing UITextView with bullet pointing and tabbing support.
//struct GrowingTextField: UIViewRepresentable {
//    @Binding var attributedText: NSAttributedString
//    @Binding var fontName: String
//    @Binding var fontSize: CGFloat
//    @Binding var fontColor: UIColor
//    @Binding var cursorColor: UIColor
//    @Binding var backgroundColor: UIColor?
//    var hasInset: Bool = true
//    @Binding var enableLinkDetection: Bool
//
//    @Binding var cursorPosition: NSRange?
//    @ObservedObject var viewModel: TextEditorViewModel
//
//    /// Creates the `UITextView` with the required configurations.
//    func makeUIView(context: Context) -> UITextView {
//        let textStorage = NSTextStorage()
//        let layoutManager = NSLayoutManager()
//        textStorage.addLayoutManager(layoutManager)
//        
//        let textContainer = NSTextContainer(size: CGSize(width: 0, height: CGFloat.greatestFiniteMagnitude))
//        textContainer.widthTracksTextView = true
//        layoutManager.addTextContainer(textContainer)
//        
//        let textView = UITextView(frame: .zero, textContainer: textContainer)
//        context.coordinator.textView = textView
//        
//        textView.backgroundColor = backgroundColor ?? .clear
//        textView.tintColor = cursorColor
//        textView.font = UIFont(name: fontName, size: fontSize)
//        textView.textColor = fontColor
//        textView.isScrollEnabled = true
//        textView.showsVerticalScrollIndicator = false
//        textView.delegate = context.coordinator
//        textView.textContainerInset = hasInset ? UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10) : .zero
//        textView.textContainer.lineFragmentPadding = 0
//        
//        return textView
//    }
//
//
//    private func updateTextView(_ textView: UITextView) {
//        let mutableAttributedString = NSMutableAttributedString(attributedString: attributedText)
//              let fullRange = NSRange(location: 0, length: mutableAttributedString.length)
//              let font = UIFont(name: fontName, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
//              
//              mutableAttributedString.addAttributes([
//                  .font: font,
//                  .foregroundColor: fontColor
//              ], range: fullRange)
//              
//        textView.attributedText = mutableAttributedString
//        textView.font = font
//        textView.textColor = fontColor
//    }
//    
//    /// Updates the `UITextView` when the attributed text changes.
////    func updateUIView(_ uiView: UITextView, context: Context) {
////        updateTextView(uiView)
////        if uiView.attributedText != attributedText {
////            uiView.attributedText = attributedText
////            if let cursorPosition = cursorPosition {
////                uiView.selectedRange = cursorPosition
////            }
////            if enableLinkDetection {
////                        let linkedText = context.coordinator.makeAttributedStringWithLinks(from: uiView.text)
////                        uiView.attributedText = NSAttributedString(linkedText)
////                    }
////        }
////    }
//    
//    func updateUIView(_ uiView: UITextView, context: Context) {
//        print("updateUIView called for GrowingTextField with text: \(attributedText)")
//        if uiView.attributedText != attributedText {
//            uiView.attributedText = attributedText
//        }
//    }
//    
//    /// Creates the coordinator for managing the `UITextView` delegate.
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self, viewModel: viewModel)
//    }
//    
//    /// Coordinator for handling `UITextView` delegate methods.
//    class Coordinator: NSObject, UITextViewDelegate {
//        var parent: GrowingTextField
//        var viewModel: TextEditorViewModel
//        var textView: UITextView?
//        private var cancellables = Set<AnyCancellable>()
//        
//        init(_ parent: GrowingTextField, viewModel: TextEditorViewModel) {//interesting
//            self.parent = parent
//            self.viewModel = viewModel
//            super.init()
//            
//            // Subscribe to style application requests from the view model
//            viewModel.$styleToApply
//                     .compactMap { $0 }
//                     .receive(on: DispatchQueue.main)
//                     .sink { [weak self] style in
//                         self?.applyStyle(style)
//                     }
//                     .store(in: &cancellables)
//                 
//            
//            // Subscribe to text insertion updates from the view model.
//            viewModel.$textToInsert
//                .compactMap { $0 }
//                .receive(on: DispatchQueue.main)
//                .sink { [weak self] textToInsert in
//                    self?.insertTextAtCursor(text: textToInsert)
//                }
//                .store(in: &cancellables)
//        }
//   
//        private func applyStyle(_ style: TextEditorViewModel.TextStyle) {
//            guard let textView = self.textView else { return }
//            let mutableAttributedString = NSMutableAttributedString(attributedString: textView.attributedText)
//            
//            // Ensure the selected range is within bounds
//            let safeRange = NSRange(location: min(textView.selectedRange.location, mutableAttributedString.length),
//                                    length: min(textView.selectedRange.length, mutableAttributedString.length - textView.selectedRange.location))
//            
//            switch style {
//            case .bold, .italic:
//                mutableAttributedString.enumerateAttribute(.font, in: safeRange, options: []) { value, subrange, _ in
//                    guard let font = value as? UIFont else { return }
//                    var newTraits = font.fontDescriptor.symbolicTraits
//                    let traitToToggle: UIFontDescriptor.SymbolicTraits = (style == .bold) ? .traitBold : .traitItalic
//                    
//                    if newTraits.contains(traitToToggle) {
//                        newTraits.remove(traitToToggle)
//                    } else {
//                        newTraits.insert(traitToToggle)
//                    }
//                    
//                    if let newFontDescriptor = font.fontDescriptor.withSymbolicTraits(newTraits) {
//                        let newFont = UIFont(descriptor: newFontDescriptor, size: font.pointSize)
//                        mutableAttributedString.addAttribute(.font, value: newFont, range: subrange)
//                    }
//                }
//            case .underline:
//                let currentUnderlineStyle = mutableAttributedString.attribute(.underlineStyle, at: safeRange.location, effectiveRange: nil) as? Int
//                let newUnderlineStyle = (currentUnderlineStyle == NSUnderlineStyle.single.rawValue) ? 0 : NSUnderlineStyle.single.rawValue
//                mutableAttributedString.addAttribute(.underlineStyle, value: newUnderlineStyle, range: safeRange)
//            }
//            
//            DispatchQueue.main.async { [weak self] in
//                guard let self = self else { return }
//                textView.attributedText = mutableAttributedString
//                self.parent.attributedText = mutableAttributedString
//                self.parent.viewModel.attributedText = mutableAttributedString
//                
//                // Update cursor position within bounds
//                let newSelectedRange = NSRange(location: min(textView.selectedRange.location, mutableAttributedString.length),
//                                               length: min(textView.selectedRange.length, mutableAttributedString.length - textView.selectedRange.location))
//                textView.selectedRange = newSelectedRange
//                self.parent.cursorPosition = newSelectedRange
//                self.parent.viewModel.updateSelectedRange(newSelectedRange)
//            }
//        }
//        func makeAttributedStringWithLinks(from string: String) -> AttributedString {
//                 guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else {
//                     return AttributedString(string)
//                 }
//                 
//                 let attributedString = NSMutableAttributedString(string: string)
//                 let matches = detector.matches(in: string, options: [], range: NSRange(location: 0, length: string.utf16.count))
//
//                 for match in matches {
//                     guard let range = Range(match.range, in: string) else { continue }
//                     let nsRange = NSRange(range, in: string)
//                     attributedString.addAttribute(.link, value: match.url!, range: nsRange)
//                 }
//
//                 return AttributedString(attributedString)
//             }
//        
//        /// Called when the text in the `UITextView` changes.
//        func textViewDidChange(_ textView: UITextView) {
//            self.textView = textView
//            let mutableAttributedString = NSMutableAttributedString(attributedString: textView.attributedText)
//            let fullRange = NSRange(location: 0, length: mutableAttributedString.length)
//            
//            // Apply font and color safely
//            let font = UIFont(name: parent.fontName, size: parent.fontSize) ?? UIFont.systemFont(ofSize: parent.fontSize)
//            safelyApplyAttributes(to: mutableAttributedString, attributes: [.font: font, .foregroundColor: parent.fontColor], range: fullRange)
//            
////            // Apply link detection if enabled
////            if parent.enableLinkDetection {
////                let linkedText = makeAttributedStringWithLinks(from: textView.text)
////                let nsLinkedText = NSAttributedString(linkedText)
////                nsLinkedText.enumerateAttributes(in: fullRange, options: []) { (attributes, range, _) in
////                    mutableAttributedString.addAttributes(attributes, range: range)
////                }
////            }
//
//            
//            DispatchQueue.main.async { [weak self] in
//                guard let self = self else { return }
//                textView.attributedText = mutableAttributedString
//                self.parent.attributedText = mutableAttributedString
//                self.parent.viewModel.attributedText = mutableAttributedString
//                
//                // Update cursor position safely
//                let newSelectedRange = NSRange(location: min(textView.selectedRange.location, mutableAttributedString.length),
//                                               length: 0)
//                textView.selectedRange = newSelectedRange
//                self.parent.cursorPosition = newSelectedRange
//                self.parent.viewModel.updateSelectedRange(newSelectedRange)
//            }
//        }
//
//        
//        /// Inserts text at the current cursor position in the `UITextView`.
//        private func insertTextAtCursor(text: String) {
//            guard let textView = self.textView else { return }
//            
//            let mutableAttributedString = NSMutableAttributedString(attributedString: textView.attributedText)
//            var range = textView.selectedRange
//            
//            // Ensure the range is within bounds
//            if range.location > mutableAttributedString.length {
//                range = NSRange(location: mutableAttributedString.length, length: 0)
//            }
//            
//            // Preserve existing attributes
//            let attributes: [NSAttributedString.Key: Any]
//            if range.location > 0 && range.location - 1 < mutableAttributedString.length {
//                attributes = textView.attributedText.attributes(at: range.location - 1, effectiveRange: nil)
//            } else {
//                attributes = [
//                    .font: textView.font ?? UIFont.systemFont(ofSize: UIFont.systemFontSize),
//                    .foregroundColor: textView.textColor ?? .black
//                ]
//            }
//            
//            if text == "\t" {
//                // Insert tab character and update cursor position
//                if range.length == 0 {
//                    mutableAttributedString.insert(NSAttributedString(string: "\t", attributes: attributes), at: range.location)
//                    range.location += 1
//                } else {
//                    let selectedText = mutableAttributedString.attributedSubstring(from: range).string
//                    let lines = selectedText.components(separatedBy: .newlines)
//                    let indentedLines = lines.map { "\t\($0)" }
//                    let updatedText = indentedLines.joined(separator: "\n")
//                    mutableAttributedString.replaceCharacters(in: range, with: NSAttributedString(string: updatedText, attributes: attributes))
//                    range.length = updatedText.utf16.count
//                }
//            } else if text == "\t• " {
//                if range.length == 0 {
//                    let bulletPoint = NSAttributedString(string: "\t• ", attributes: attributes)
//                    mutableAttributedString.insert(bulletPoint, at: range.location)
//                    range.location += bulletPoint.length
//                } else {
//                    // Text is selected, apply bullet point to the first line and indent the rest
//                    let selectedText = mutableAttributedString.attributedSubstring(from: range).string
//                    var lines = selectedText.components(separatedBy: .newlines)
//                    lines[0] = "\t• " + lines[0] // Add bullet point and tab to the first line
//                    for i in 1..<lines.count {
//                        lines[i] = "\t" + lines[i] // Indent remaining lines
//                    }
//                    let updatedText = lines.joined(separator: "\n")
//                    mutableAttributedString.replaceCharacters(in: range, with: NSAttributedString(string: updatedText, attributes: attributes))
//                    range.length = updatedText.utf16.count
//                }
//            } else {
//                // Insert text and update cursor position
//                mutableAttributedString.replaceCharacters(in: range, with: NSAttributedString(string: text, attributes: attributes))
//                range.location += text.utf16.count
//                range.length = 0
//            }
//            
//            textView.attributedText = mutableAttributedString
//            textView.selectedRange = range
//            parent.cursorPosition = range // Ensure cursor position is updated correctly
//            parent.attributedText = mutableAttributedString
//            
//            // Force the UITextView to update its selection
//            DispatchQueue.main.async {
//                textView.becomeFirstResponder()
//                textView.selectedRange = range
//            }
//        }
//        
//        /// Updates the height of the `UITextView` based on its content.
//        func updateTextViewHeight(_ textView: UITextView) {
//            let size = textView.sizeThatFits(CGSize(width: textView.frame.width, height: CGFloat.greatestFiniteMagnitude))
//            textView.contentSize = size
//        }
//        
//        /// Handles text changes in the `UITextView`.
//        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//            return true
//        }
//        
//        
//    }
//}
//
///// ViewModel for managing text in the RichTextEditor.
//class TextEditorViewModel: ObservableObject {
//    @Published var text: String = ""
//    @Published var attributedText: NSAttributedString = NSAttributedString(string: "")
//
//    @Published var textToInsert: String?
//    
//    @Published var selectedRange: NSRange = NSRange(location: 0, length: 0)
//    @Published var styleToApply: TextStyle?
//
//       enum TextStyle {
//           case bold, italic, underline
//       }
//    
//    func applyStyle(_ style: TextStyle) {
//         styleToApply = style
//     }
//       
//       func updateSelectedRange(_ range: NSRange) {
//           selectedRange = range
//       }
//     
//     func insertText(_ text: String, at range: NSRange) {
//         let mutableAttributedString = NSMutableAttributedString(attributedString: attributedText)
//         mutableAttributedString.replaceCharacters(in: range, with: text)
//         attributedText = mutableAttributedString
//     }
//    
//    /// Inserts the specified text into the editor.
//    func insertText() {
//        guard let textToInsert = textToInsert else { return }
//        text.append(textToInsert)
//        self.textToInsert = nil
//    }
//    
//    /// Adds a bullet point to the text.
//    func addBulletPoint() {
//        let bulletPoint = "\t• "
//        text.append("\(bulletPoint)")
//    }
//    
//    /// Inserts a tab character into the text.
//    func insertTab() {
//        let tab = "\t"
//        text.append(tab)
//    }
//}
//
///// Extension to convert a `Binding<String>` to `Binding<NSAttributedString>`.
//extension Binding where Value == String {
//    /// Converts a `Binding<String>` to `Binding<NSAttributedString>` with the specified font and color.
//    func asAttributedString(fontName: String, fontSize: CGFloat, fontColor: UIColor) -> Binding<NSAttributedString> {
//        Binding<NSAttributedString>(
//            get: {
//                let attributes: [NSAttributedString.Key: Any] = [
//                    .font: UIFont(name: fontName, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize),
//                    .foregroundColor: fontColor
//                ]
//                return NSAttributedString(string: self.wrappedValue, attributes: attributes)
//            },
//            set: { newValue in
//                self.wrappedValue = newValue.string
//            }
//        )
//    }
//}
