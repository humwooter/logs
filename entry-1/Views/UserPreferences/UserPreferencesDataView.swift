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
    @State private var isHidden = true
    
    @Binding  var showNotification: Bool
    @Binding  var isSuccess: Bool
    @Binding  var isFailure: Bool
    @State private var notificationMessage = ""
    
    func getIdealHeaderTextColor() -> Color {
        return Color(UIColor.fontColor(forBackgroundColor: UIColor.averageColor(of: UIColor(userPreferences.backgroundColors.first ?? Color.clear), and: UIColor(userPreferences.backgroundColors[1])), colorScheme: colorScheme))
    }   
    
    
    var body: some View {
        
        Section {
            if !isHidden {
                mainView()
            }
        } header: {
            HStack {
                Image(systemName: "paintpalette.fill").foregroundStyle(userPreferences.accentColor).padding(.horizontal, 5)
                Text("Preferences Data").foregroundStyle(getIdealHeaderTextColor().opacity(0.4))

                Spacer()
                Image(systemName: isHidden ? "chevron.down" : "chevron.up").foregroundStyle(userPreferences.accentColor).padding(.horizontal, 5)
            }
            .font(.system(size: UIFont.systemFontSize))
            .onTapGesture {
                isHidden.toggle()
            }
        }

    }

    @ViewBuilder
    func mainView() -> some View {
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
            .fileExporter(isPresented: $isExporting, document: UserPreferencesDocument(userPreferences: userPreferences), contentType: .json, defaultFilename: "my theme - \(formattedDateShort(from: Date())).json") { result in
                switch result {
                case .success(let url):
                    showNotification = true
                    isSuccess = true
                    isFailure = false
                    notificationMessage = "Preferences Export Complete"
                    print("File successfully saved at \(url)")
                case .failure(let error):
                    showNotification = true
                    isSuccess = false
                    isFailure = true
                    notificationMessage = "Preferences Export Cancelled"
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
                    showNotification = true
                    isSuccess = true
                    isFailure = false
                    notificationMessage = "Preferences Import Complete"
                case .failure(let error):
                    showNotification = true
                    isSuccess = false
                    isFailure = true
                    notificationMessage = "Preferences Import Cancelled"
                    print("Failed to import file: \(error)")
                }
            }
            .alert(isPresented: $showNotification) {
                if isSuccess {
                    Alert(title: Text("Success"), message: Text(notificationMessage), dismissButton: .default(Text("OK")))
                } else if isFailure {
                    Alert(title: Text("Failure"), message: Text("Data failed to export or import"), dismissButton: .default(Text("OK")))
                } else{
                    Alert(title: Text("Failure"), message: Text("Data failed to export or import"), dismissButton: .default(Text("OK")))
                }
              }

            Spacer()
        }
        .zIndex(1) // Ensure it lays on top if using ZStack
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


