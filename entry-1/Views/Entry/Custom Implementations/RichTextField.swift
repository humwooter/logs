////
////  RichTextField.swift
////  entry-1
////
////  Created by Katyayani G. Raman on 6/30/24.
////
//
//import Foundation
//
//#if os(iOS) || os(tvOS)
//import UIKit
//
//public class RichTextView: UITextView {}
//#endif
//
//#if os(macOS)
//import AppKit
//
//public class RichTextView: NSTextView {}
//#endif
//
//public protocol RichTextViewRepresentable {
//    var attributedString: NSAttributedString { get set }
//    var mutableAttributedString: NSMutableAttributedString? { get }
//}
//
//#if os(iOS) || os(tvOS)
//extension RichTextView: RichTextViewRepresentable {
//    public var attributedString: NSAttributedString {
//        get { attributedText ?? NSAttributedString(string: "") }
//        set { attributedText = newValue }
//    }
//    
//    public var mutableAttributedString: NSMutableAttributedString? {
//        return textStorage
//    }
//}
//#endif
//
//#if os(macOS)
//extension RichTextView: RichTextViewRepresentable {
//    public var attributedString: NSAttributedString {
//        get { attributedString() }
//        set { textStorage?.setAttributedString(newValue) }
//    }
//    
//    public var mutableAttributedString: NSMutableAttributedString? {
//        return textStorage
//    }
//}
//#endif
//
//
//public class RichTextContext: ObservableObject {
//    @Published public var isUnderlined = false
//    @Published public var isBold = false
//    @Published public var isItalic = false
//    
//    public init() {}
//}
