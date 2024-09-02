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
    
    @EnvironmentObject var userPreferences: UserPreferences
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            FlowLayout(tags: tags, userPreferences: userPreferences, colorScheme: colorScheme)
        }
    }
}

struct FlowLayout: View {
    let tags: [String]
    let spacing: CGFloat = 8
    let userPreferences: UserPreferences
    let colorScheme: ColorScheme
    
    var body: some View {
        var width: CGFloat = 0
        var lines: [[String]] = [[]]
        
        // Group tags into lines that fit within the screen width
        for tag in tags {
            let tagWidth = tag.widthOfString(usingFont: UIFont.systemFont(ofSize: 12)) + 16 // 16 for padding
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
                            .font(.customCaption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
//                            .background(userPreferences.accentColor.opacity(0.2))
                            .cornerRadius(12)
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



struct TagSelectionPopup: View {
    @Binding var isPresented: Bool
    @Binding var entryId: UUID
    @Binding var selectedTagNames: [String]
    @State private var newTagName: String = ""
    @State private var refreshID = UUID()
    
    @ObservedObject var tagViewModel: TagViewModel

    @EnvironmentObject var userPreferences: UserPreferences
    @EnvironmentObject var coreDataManager: CoreDataManager
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            // New Tag Input Section
            HStack {
                TextField("Create new tag", text: $newTagName, prompt: Text("Enter tag name")
                    .foregroundStyle(getTextColor().opacity(0.5)))
                    .textFieldStyle(.plain)
                    .padding()
                    .font(.buttonSize)
                    .foregroundStyle(getTextColor())
                    .background(
                        RoundedRectangle(cornerRadius: 15).fill(userPreferences.entryBackgroundColor)
                            .stroke(getTextColor().opacity(0.2), lineWidth: 1)
                    )

                Button(action: {
                    tagViewModel.addNewTag(newTagName)
                    newTagName = ""
                    refreshID = UUID()
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(userPreferences.accentColor)
                }
                .padding(.trailing)
                .disabled(newTagName.isEmpty)
            }
            .padding(.horizontal)
            .padding(.vertical)

            // Tag Selection Grid
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]) {
                    ForEach(Array(tagViewModel.currentTags.keys), id: \.self) { tagName in
                        TagButton(
                            tagName: tagName,
                            isSelected: tagViewModel.currentTags[tagName] ?? false,
                            action: { tagViewModel.toggleTagSelection(tagName) },
                            userPreferences: userPreferences,
                            colorScheme: colorScheme
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
        .cornerRadius(20)
        .id(refreshID)
        .onAppear {
            tagViewModel.initializeCurrentTags(with: selectedTagNames)
        }
    }
    
    func getTextColor() -> Color {
        let background1 = userPreferences.backgroundColors.first ?? Color.clear
        let background2 = userPreferences.backgroundColors[1]
        let entryBackground = getSectionColor()
        
        return calculateTextColor(
            basedOn: background1,
            background2: background2,
            entryBackground: entryBackground,
            colorScheme: colorScheme
        )
    }
    
    func getSectionColor() -> Color {
        if isClear(for: UIColor(userPreferences.entryBackgroundColor)) {
            return getDefaultEntryBackgroundColor(colorScheme: colorScheme)
        }
        return userPreferences.entryBackgroundColor
    }
}

struct TagButton: View {
    let tagName: String
    let isSelected: Bool
    let action: () -> Void
    
    let userPreferences: UserPreferences
    let colorScheme: ColorScheme
    
    var body: some View {
        Button(action: action) {
            Text(tagName)
                .font(.customCaption)
                .padding()
                .background(isSelected ? userPreferences.accentColor : getSectionColor())
                .foregroundColor(isSelected ? getSelectedTextColor() : getTextColor())
                .cornerRadius(20)
        }
    }
    
    func getSectionColor() -> Color {
        if isSelected {
            return userPreferences.accentColor
        }
        if isClear(for: UIColor(userPreferences.entryBackgroundColor)) {
            return getDefaultEntryBackgroundColor(colorScheme: colorScheme)
        }
        return userPreferences.entryBackgroundColor
    }
    
    func getSelectedTextColor() -> Color {
        return Color(UIColor.fontColor(forBackgroundColor: UIColor(userPreferences.accentColor)))
    }
    
    func getTextColor() -> Color {
        let background1 = userPreferences.backgroundColors.first ?? Color.clear
        let background2 = userPreferences.backgroundColors[1]
        let entryBackground = getSectionColor()
        
        return calculateTextColor(
            basedOn: background1,
            background2: background2,
            entryBackground: entryBackground,
            colorScheme: colorScheme
        )
    }
}
