//
//  StampDataView.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 2/21/24.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct StampDataView: View {
    @EnvironmentObject var userPreferences: UserPreferences
    @State  var stamps: [Stamp] // Changed to handle a list of stamps
    @State private var isExporting = false
    @State private var isImporting = false
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Section(header: Text("Stamp Data").foregroundStyle(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color.gray))).opacity(0.4)
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
                .fileExporter(isPresented: $isExporting, document: StampsDocument(stamps: stamps), contentType: .json, defaultFilename: "stamp data backup - \(formattedDateShort(from: Date())).json") { result in
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
                        importStamps(from: url)
                    case .failure(let error):
                        print("Failed to import file: \(error)")
                    }
                }

                Spacer()
            }
            .zIndex(1) // Ensure it lays on top if using ZStack
        }
    }

    func importStamps(from url: URL) {
        let accessGranted = url.startAccessingSecurityScopedResource()
        defer { url.stopAccessingSecurityScopedResource() }
        
        guard accessGranted else {
            print("Failed to access file: Permission denied")
            return
        }
        
        do {
            let jsonData = try Data(contentsOf: url)
            let importedStamps = try JSONDecoder().decode([Stamp].self, from: jsonData) // Decode an array of Stamp
          
            self.stamps = importedStamps // Update the state with the imported stamps
        } catch {
            print("Failed to import file: \(error)")
        }
    }
}