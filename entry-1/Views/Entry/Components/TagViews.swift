//
//  TagViews.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 8/26/24.
//
import SwiftUI
import Foundation
 
struct FlexibleTagGridView: View {
    let tags: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            FlowLayout(tags: tags)
        }
    }
}

struct FlowLayout: View {
    let tags: [String]
    let spacing: CGFloat = 5
    
    var body: some View {
        var width: CGFloat = 0
        var lines: [[String]] = [[]]
        
        // Group tags into lines that fit within the screen width
        for tag in tags {
            let tagWidth = tag.widthOfString(usingFont: .systemFont(ofSize: 10)) + 10 // 20 for padding
            if width + tagWidth + spacing > UIScreen.main.bounds.width - 32 {
                width = tagWidth
                lines.append([tag])
            } else {
                lines[lines.count - 1].append(tag)
                width += tagWidth + spacing
            }
        }
        
        return VStack(alignment: .leading, spacing: spacing) {
            ForEach(lines, id: \.self) { line in
                HStack(spacing: spacing) {
                    ForEach(line, id: \.self) { tag in
                        Text("#\(tag)")
                            .font(.caption)
                            .cornerRadius(5)
                            .lineLimit(1)
                    }
                }
            }
        }
    }
}

extension String {
    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        return self.size(withAttributes: fontAttributes).width
    }
}

