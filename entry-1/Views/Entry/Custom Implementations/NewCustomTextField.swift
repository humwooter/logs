//
//  NewCustomTextField.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 7/10/24.
//


//WORKING VERSION AS OF JULY 10
import Foundation
import SwiftUI
import UIKit
import Combine

/// A SwiftUI wrapper for a growing UITextView with bullet pointing and tabbing support.
struct GrowingTextField: UIViewRepresentable {
    @Binding var attributedText: NSAttributedString
    @Binding var fontName: String
    @Binding var fontSize: CGFloat
    @Binding var fontColor: UIColor
    @Binding var cursorColor: UIColor
    @Binding var backgroundColor: UIColor?
    var hasInset: Bool = true
    @Binding var enableLinkDetection: Bool

    @Binding var cursorPosition: NSRange?
    @ObservedObject var viewModel: TextEditorViewModel

    /// Creates the `UITextView` with the required configurations.
    func makeUIView(context: Context) -> UITextView {
        let textStorage = NSTextStorage()
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        
        let textContainer = NSTextContainer(size: CGSize(width: 0, height: CGFloat.greatestFiniteMagnitude))
        textContainer.widthTracksTextView = true
        layoutManager.addTextContainer(textContainer)
        
        let textView = UITextView(frame: .zero, textContainer: textContainer)
        context.coordinator.textView = textView
        
        textView.backgroundColor = backgroundColor ?? .clear
        textView.tintColor = cursorColor
        textView.font = UIFont(name: fontName, size: fontSize)
        textView.textColor = fontColor
        textView.isScrollEnabled = true
        textView.showsVerticalScrollIndicator = false
        textView.delegate = context.coordinator
        textView.textContainerInset = hasInset ? UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10) : .zero
        textView.textContainer.lineFragmentPadding = 0
        
        return textView
    }

    private func updateTextView(_ textView: UITextView) {
        let mutableAttributedString = NSMutableAttributedString(attributedString: attributedText)
        let fullRange = NSRange(location: 0, length: mutableAttributedString.length)
        let font = UIFont(name: fontName, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
        
        mutableAttributedString.addAttributes([
            .font: font,
            .foregroundColor: fontColor
        ], range: fullRange)
        
        textView.attributedText = mutableAttributedString
        textView.font = font
        textView.textColor = fontColor
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.attributedText != attributedText {
            uiView.attributedText = attributedText
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, viewModel: viewModel)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: GrowingTextField
        var viewModel: TextEditorViewModel
        var textView: UITextView?
        private var cancellables = Set<AnyCancellable>()
        
        init(_ parent: GrowingTextField, viewModel: TextEditorViewModel) {
            self.parent = parent
            self.viewModel = viewModel
            super.init()
            
            viewModel.$styleToApply
                .compactMap { $0 }
                .receive(on: DispatchQueue.main)
                .sink { [weak self] style in
                    self?.applyStyle(style)
                }
                .store(in: &cancellables)
            
            viewModel.$textToInsert
                .compactMap { $0 }
                .receive(on: DispatchQueue.main)
                .sink { [weak self] textToInsert in
                    self?.insertTextAtCursor(text: textToInsert)
                }
                .store(in: &cancellables)
        }
   
        private func applyStyle(_ style: TextEditorViewModel.TextStyle) {
            guard let textView = self.textView else { return }
            let mutableAttributedString = NSMutableAttributedString(attributedString: textView.attributedText)
            
            let safeRange = NSRange(location: min(textView.selectedRange.location, mutableAttributedString.length),
                                    length: min(textView.selectedRange.length, mutableAttributedString.length - textView.selectedRange.location))
            
            switch style {
            case .bold, .italic:
                mutableAttributedString.enumerateAttribute(.font, in: safeRange, options: []) { value, subrange, _ in
                    guard let font = value as? UIFont else { return }
                    var newTraits = font.fontDescriptor.symbolicTraits
                    let traitToToggle: UIFontDescriptor.SymbolicTraits = (style == .bold) ? .traitBold : .traitItalic
                    
                    if newTraits.contains(traitToToggle) {
                        newTraits.remove(traitToToggle)
                    } else {
                        newTraits.insert(traitToToggle)
                    }
                    
                    if let newFontDescriptor = font.fontDescriptor.withSymbolicTraits(newTraits) {
                        let newFont = UIFont(descriptor: newFontDescriptor, size: font.pointSize)
                        mutableAttributedString.addAttribute(.font, value: newFont, range: subrange)
                    }
                }
            case .underline:
                let currentUnderlineStyle = mutableAttributedString.attribute(.underlineStyle, at: safeRange.location, effectiveRange: nil) as? Int
                let newUnderlineStyle = (currentUnderlineStyle == NSUnderlineStyle.single.rawValue) ? 0 : NSUnderlineStyle.single.rawValue
                mutableAttributedString.addAttribute(.underlineStyle, value: newUnderlineStyle, range: safeRange)
            }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                textView.attributedText = mutableAttributedString
                self.parent.attributedText = mutableAttributedString
                self.parent.viewModel.attributedText = mutableAttributedString
                
                let newSelectedRange = NSRange(location: min(textView.selectedRange.location, mutableAttributedString.length),
                                               length: min(textView.selectedRange.length, mutableAttributedString.length - textView.selectedRange.location))
                textView.selectedRange = newSelectedRange
                self.parent.cursorPosition = newSelectedRange
                self.parent.viewModel.updateSelectedRange(newSelectedRange)
            }
        }
        
        func makeAttributedStringWithLinks(from string: String) -> AttributedString {
            guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else {
                return AttributedString(string)
            }
            
            let attributedString = NSMutableAttributedString(string: string)
            let matches = detector.matches(in: string, options: [], range: NSRange(location: 0, length: string.utf16.count))

            for match in matches {
                guard let range = Range(match.range, in: string) else { continue }
                let nsRange = NSRange(range, in: string)
                attributedString.addAttribute(.link, value: match.url!, range: nsRange)
            }

            return AttributedString(attributedString)
        }
        
        func textViewDidChange(_ textView: UITextView) {
            self.textView = textView
            let mutableAttributedString = NSMutableAttributedString(attributedString: textView.attributedText)
            let fullRange = NSRange(location: 0, length: mutableAttributedString.length)
            
            let font = UIFont(name: parent.fontName, size: parent.fontSize) ?? UIFont.systemFont(ofSize: parent.fontSize)
            safelyApplyAttributes(to: mutableAttributedString, attributes: [.font: font, .foregroundColor: parent.fontColor], range: fullRange)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                textView.attributedText = mutableAttributedString
                self.parent.attributedText = mutableAttributedString
                self.parent.viewModel.attributedText = mutableAttributedString
                
                let newSelectedRange = NSRange(location: min(textView.selectedRange.location, mutableAttributedString.length),
                                               length: 0)
                textView.selectedRange = newSelectedRange
                self.parent.cursorPosition = newSelectedRange
                self.parent.viewModel.updateSelectedRange(newSelectedRange)
            }
        }
        
        private func safelyApplyAttributes(to attributedString: NSMutableAttributedString, attributes: [NSAttributedString.Key: Any], range: NSRange) {
            let safeRange = NSRange(location: min(range.location, attributedString.length),
                                    length: min(range.length, attributedString.length - range.location))
            attributedString.addAttributes(attributes, range: safeRange)
        }
        
        private func insertTextAtCursor(text: String) {
            guard let textView = self.textView else { return }
            
            let mutableAttributedString = NSMutableAttributedString(attributedString: textView.attributedText)
            var range = textView.selectedRange
            
            if range.location > mutableAttributedString.length {
                range = NSRange(location: mutableAttributedString.length, length: 0)
            }
            
            let attributes: [NSAttributedString.Key: Any]
            if range.location > 0 && range.location - 1 < mutableAttributedString.length {
                attributes = textView.attributedText.attributes(at: range.location - 1, effectiveRange: nil)
            } else {
                attributes = [
                    .font: textView.font ?? UIFont.systemFont(ofSize: UIFont.systemFontSize),
                    .foregroundColor: textView.textColor ?? .black
                ]
            }
            
            if

 text == "\t" {
                if range.length == 0 {
                    mutableAttributedString.insert(NSAttributedString(string: "\t", attributes: attributes), at: range.location)
                    range.location += 1
                } else {
                    let selectedText = mutableAttributedString.attributedSubstring(from: range).string
                    let lines = selectedText.components(separatedBy: .newlines)
                    let indentedLines = lines.map { "\t\($0)" }
                    let updatedText = indentedLines.joined(separator: "\n")
                    mutableAttributedString.replaceCharacters(in: range, with: NSAttributedString(string: updatedText, attributes: attributes))
                    range.length = updatedText.utf16.count
                }
            } else if text == "\t• " {
                if range.length == 0 {
                    let bulletPoint = NSAttributedString(string: "\t• ", attributes: attributes)
                    mutableAttributedString.insert(bulletPoint, at: range.location)
                    range.location += bulletPoint.length
                } else {
                    let selectedText = mutableAttributedString.attributedSubstring(from: range).string
                    var lines = selectedText.components(separatedBy: .newlines)
                    lines[0] = "\t• " + lines[0]
                    for i in 1..<lines.count {
                        lines[i] = "\t" + lines[i]
                    }
                    let updatedText = lines.joined(separator: "\n")
                    mutableAttributedString.replaceCharacters(in: range, with: NSAttributedString(string: updatedText, attributes: attributes))
                    range.length = updatedText.utf16.count
                }
            } else {
                mutableAttributedString.replaceCharacters(in: range, with: NSAttributedString(string: text, attributes: attributes))
                range.location += text.utf16.count
                range.length = 0
            }
            
            textView.attributedText = mutableAttributedString
            textView.selectedRange = range
            parent.cursorPosition = range
            parent.attributedText = mutableAttributedString
            
            DispatchQueue.main.async {
                textView.becomeFirstResponder()
                textView.selectedRange = range
            }
        }
        
        func updateTextViewHeight(_ textView: UITextView) {
            let size = textView.sizeThatFits(CGSize(width: textView.frame.width, height: CGFloat.greatestFiniteMagnitude))
            textView.contentSize = size
        }
        
        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            return true
        }
    }
}

class TextEditorViewModel: ObservableObject {
    @Published var text: String = ""
    @Published var attributedText: NSAttributedString = NSAttributedString(string: "")
    @Published var textToInsert: String?
    @Published var selectedRange: NSRange = NSRange(location: 0, length: 0)
    @Published var styleToApply: TextStyle?

    enum TextStyle {
        case bold, italic, underline
    }
    
    func applyStyle(_ style: TextStyle) {
        styleToApply = style
    }
    
    func updateSelectedRange(_ range: NSRange) {
        selectedRange = range
    }
    
    func insertText(_ text: String, at range: NSRange) {
        let mutableAttributedString = NSMutableAttributedString(attributedString: attributedText)
        mutableAttributedString.replaceCharacters(in: range, with: text)
        attributedText = mutableAttributedString
    }
    
    func insertText() {
        guard let textToInsert = textToInsert else { return }
        text.append(textToInsert)
        self.textToInsert = nil
    }
    
    func addBulletPoint() {
        let bulletPoint = "\t• "
        text.append("\(bulletPoint)")
    }
    
    func insertTab() {
        let tab = "\t"
        text.append(tab)
    }
}

extension Binding where Value == String {
    func asAttributedString(fontName: String, fontSize: CGFloat, fontColor: UIColor) -> Binding<NSAttributedString> {
        Binding<NSAttributedString>(
            get: {
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont(name: fontName, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize),
                    .foregroundColor: fontColor
                ]
                return NSAttributedString(string: self.wrappedValue, attributes: attributes)
            },
            set: { newValue in
                self.wrappedValue = newValue.string
            }
        )
    }
}
