//
//  UserPreferencesDataView.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 2/13/24.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct UserPreferencesView: View {
    @EnvironmentObject var userPreferences: UserPreferences
    @State private var isExporting = false
    @State private var isImporting = false
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Section(header: Text("Preferences Data").foregroundStyle(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color.gray))).opacity(0.4)
                    .font(.system(size: UIFont.systemFontSize))
        ) {
            HStack {
                Spacer()
                Button {
                    print("Export button tapped")
                    isExporting = true
                } label: {
                    VStack(spacing: 2) {
                        Image(systemName: "arrow.up.doc")
                        Text("BACKUP").fontWeight(.bold).font(.custom(userPreferences.fontName, size: CGFloat(userPreferences.fontSize)))
                    }
                }
                .buttonStyle(BackupButtonStyle())
                .foregroundColor(Color(UIColor.tertiarySystemBackground))
                .fileExporter(isPresented: $isExporting, document: UserPreferencesDocument(userPreferences: userPreferences), contentType: .json, defaultFilename: "logs user preferences backup.json") { result in
                    switch result {
                    case .success(let url):
                        print("File successfully saved at \(url)")
                    case .failure(let error):
                        print("Failed to save file: \(error)")
                    }
                }

                Spacer()
                Button {
                    isImporting = true
                } label: {
                    VStack(spacing: 2) {
                        Image(systemName: "arrow.down.doc")
                        Text("RESTORE").fontWeight(.bold).font(.custom(userPreferences.fontName, size: CGFloat(userPreferences.fontSize)))
                    }
                }
                .buttonStyle(RestoreButtonStyle())
                .foregroundColor(colorScheme == .dark ? .black : .white)
                .fileImporter(isPresented: $isImporting, allowedContentTypes: [.json]) { result in
                    switch result {
                    case .success(let url):
                        importUserPreferences(from: url)
                    case .failure(let error):
                        print("Failed to import file: \(error)")
                    }
                }

                Spacer()
            }
            .zIndex(1) // Ensure it lays on top if using ZStack
        }
    }


    func importUserPreferences(from url: URL) {
        let accessGranted = url.startAccessingSecurityScopedResource() // Start accessing the resource
        defer { url.stopAccessingSecurityScopedResource() } // Ensure we stop accessing the resource when done
        
        guard accessGranted else {
            print("Failed to access file: Permission denied")
            return
        }
        
        do {
            let jsonData = try Data(contentsOf: url)
            let importedPreferences = try JSONDecoder().decode(UserPreferences.self, from: jsonData)
          
            self.userPreferences.update(from: importedPreferences)
        } catch {
            print("Failed to import file: \(error)")
        }
    }
}


