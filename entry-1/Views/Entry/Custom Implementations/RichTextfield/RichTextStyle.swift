//
//  RichTextStyle.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 7/11/24.
//

import UIKit
import Foundation
import SwiftUI


public enum RichTextStyle: String, Hashable {
    case bold
    case italic
    case underline
    case h1
    case h2
    case h3
    case h4
    case h5
    case h6

    var attributedStringKey: NSAttributedString.Key {
        switch self {
        case .underline: return .underlineStyle
        default: return .font
        }
    }

    func defaultAttributeValue(font: UIFont? = nil) -> Any {
        let font = font ?? .systemFont(ofSize: 14)
        switch self {
        case .underline:
            return NSUnderlineStyle.single.rawValue
        case .bold:
            return UIFont(descriptor: font.fontDescriptor.withSymbolicTraits(.traitBold) ?? font.fontDescriptor, size: font.pointSize)
        case .italic:
            return UIFont(descriptor: font.fontDescriptor.withSymbolicTraits(.traitItalic) ?? font.fontDescriptor, size: font.pointSize)
        case .h1:
            return UIFont(descriptor: font.fontDescriptor.withSymbolicTraits(.traitBold) ?? font.fontDescriptor, size: 24)
        case .h2:
            return UIFont(descriptor: font.fontDescriptor.withSymbolicTraits(.traitBold) ?? font.fontDescriptor, size: 22)
        case .h3:
            return UIFont(descriptor: font.fontDescriptor.withSymbolicTraits(.traitBold) ?? font.fontDescriptor, size: 20)
        case .h4:
            return UIFont(descriptor: font.fontDescriptor.withSymbolicTraits(.traitBold) ?? font.fontDescriptor, size: 18)
        case .h5:
            return UIFont(descriptor: font.fontDescriptor.withSymbolicTraits(.traitBold) ?? font.fontDescriptor, size: 16)
        case .h6:
            return UIFont(descriptor: font.fontDescriptor.withSymbolicTraits(.traitBold) ?? font.fontDescriptor, size: 14)
        }
    }

    func getFontWithUpdating(font: UIFont) -> UIFont {
        switch self {
        case .bold:
            return UIFont(descriptor: font.fontDescriptor.withSymbolicTraits(.traitBold) ?? font.fontDescriptor, size: font.pointSize)
        case .italic:
            return UIFont(descriptor: font.fontDescriptor.withSymbolicTraits(.traitItalic) ?? font.fontDescriptor, size: font.pointSize)
        case .h1, .h2, .h3, .h4, .h5, .h6:
            return self.defaultAttributeValue(font: font) as! UIFont
        default:
            return font
        }
    }

    func styles() -> [RichTextStyle] {
        return [self]
    }
}
