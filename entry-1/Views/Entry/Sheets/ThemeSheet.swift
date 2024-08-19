//
//  ThemeSheet.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 8/17/24.
//

import SwiftUI
import Foundation
import ZIPFoundation
import UniformTypeIdentifiers
import QuickLookThumbnailing

struct Theme: Identifiable {
    let id = UUID()
    var name: String
    var accentColor: Color
    var topColor: Color
    var bottomColor: Color
    var entryBackgroundColor: Color
    var pinColor: Color
    var reminderColor: Color
    var fontName: String
    var fontSize: CGFloat
    var lineSpacing: CGFloat
}

struct ThemeSheet: View {
    @EnvironmentObject var userPreferences: UserPreferences
    @EnvironmentObject var coreDataManager: CoreDataManager
    @Environment(\.displayScale) var displayScale

    @Environment(\.colorScheme) var colorScheme
    @FetchRequest(
          entity: UserTheme.entity(),
          sortDescriptors: []
      ) var savedThemes: FetchedResults<UserTheme>
    
    @State var selectedTheme: UserTheme?
    @State private var editTheme = false
    @State private var showDocumentPicker = false

    private var isEditThemeActive: Binding<Bool> {
           Binding<Bool>(
               get: {
                   selectedTheme != nil && editTheme
               },
               set: { newValue in
                   // This setter can be used to control editTheme and selectedTheme state
                   if !newValue {
                       editTheme = false
                       selectedTheme = nil
                   }
               }
           )
       }
    
    var body: some View {
        ScrollView {
            customThemesView()
            defaultThemesView()
        }
        .background {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                LinearGradient(colors: [userPreferences.backgroundColors[0], userPreferences.backgroundColors.count > 1 ? userPreferences.backgroundColors[1] : userPreferences.backgroundColors[0]], startPoint: .top, endPoint: .bottom)
            }
            .ignoresSafeArea()
        }
        .scrollContentBackground(.hidden)
        .navigationBarTitleTextColor(Color(UIColor.fontColor(forBackgroundColor: UIColor(userPreferences.backgroundColors.first ?? Color.clear), colorScheme: colorScheme)))
        .font(.custom(String(userPreferences.fontName), size: CGFloat(Float(userPreferences.fontSize))))
        .accentColor(userPreferences.accentColor)
        .sheet(isPresented: isEditThemeActive) {
            EditUserThemeView(userTheme: $selectedTheme)
                .environmentObject(coreDataManager)
                .environmentObject(userPreferences)
        }
        .fileImporter(
            
            isPresented: $showDocumentPicker,
                    allowedContentTypes: [UTType(filenameExtension: "themePkg")!],
                    allowsMultipleSelection: false
                ) { result in
                    handleImport(result: result)
                }
                .toolbar {
                    Button(action: { showDocumentPicker = true }) {
                        Label("Import Theme", systemImage: "square.and.arrow.down")
                    }
                }
    }
    @ViewBuilder
    func currentThemeView() -> some View {
        let currentTheme = Theme(
            name: "Current Theme",
            accentColor: userPreferences.accentColor,
            topColor: userPreferences.backgroundColors.first ?? .clear,
            bottomColor: userPreferences.backgroundColors.last ?? .clear,
            entryBackgroundColor: userPreferences.entryBackgroundColor,
            pinColor: userPreferences.pinColor,
            reminderColor: userPreferences.reminderColor,
            fontName: userPreferences.fontName,
            fontSize: userPreferences.fontSize,
            lineSpacing: userPreferences.lineSpacing
        )
        themeView(theme: currentTheme)
        .contextMenu {
            Button("Save") {
                let userTheme = UserTheme(context: coreDataManager.viewContext)
                userTheme.fromTheme(currentTheme)
                do {
                    try coreDataManager.viewContext.save()
                } catch {
                    print("Failed to save theme: \(error.localizedDescription)")
                }
            }
        }
    }
    
    @ViewBuilder
    func customThemesView() -> some View {
        HStack {
            Text("Custom Themes").font(.headline).padding()
                .foregroundStyle(Color(UIColor.fontColor(forBackgroundColor: UIColor(userPreferences.backgroundColors.first ?? Color.clear))))
            Spacer()
        }
        
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
            currentThemeView()
            ForEach(savedThemes, id: \.id) { userTheme in
                let theme = userTheme.toTheme()
                VStack {
                    HStack {
                        Spacer()
                        Menu {
                            Button {
                                userPreferences.applyTheme(theme)
                            } label: {
                                Label("Apply", systemImage: "checkmark.circle")
                            }
                            
                            Button {
                                selectedTheme = userTheme
                                editTheme = true
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            
                            Button {
                                Task {
                                    await shareTheme(userTheme)
                                }
                            } label: {
                                Label("Share", systemImage: "square.and.arrow.up")
                            }
                            
                            Button {
                                do {
                                    try coreDataManager.viewContext.delete(userTheme)
                                    try coreDataManager.viewContext.save()
                                } catch {
                                    print("Failed to save theme: \(error.localizedDescription)")
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        } label: {
                            Label("", systemImage: "ellipsis.circle").foregroundStyle(Color(UIColor.fontColor(forBackgroundColor: userTheme.topColor ?? UIColor.clear)).opacity(0.3))
                                .frame(maxWidth: 10, maxHeight: 10)
                        }.padding(2)
                    }
                    themeView(theme: theme)
                }
                    .contextMenu {
                        Button {
                            userPreferences.applyTheme(theme)
                        } label: {
                            Label("Apply", systemImage: "checkmark.circle")
                        }
                        
                        Button {
                            selectedTheme = userTheme
                            editTheme = true
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        
                        Button {
                            Task {
                                await shareTheme(userTheme)
                            }
                        } label: {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                        
                        Button {
                            do {
                                try coreDataManager.viewContext.delete(userTheme)
                                try coreDataManager.viewContext.save()
                            } catch {
                                print("Failed to save theme: \(error.localizedDescription)")
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }

            }.onAppear {
                print("ALL SAVED THEMES")
                print(savedThemes)
            }
        }
        .padding()
    }
    
    private func deleteAllUserThemes() {
        for userTheme in savedThemes {
            do {
                try coreDataManager.viewContext.delete(userTheme)
                try coreDataManager.viewContext.save()
            } catch {
                print("Failed to delete theme: \(error.localizedDescription)")
            }
        }
    }
    
    @ViewBuilder
    func defaultThemesView() -> some View {
        HStack {
            Text("Default Themes").font(.headline).padding()
            .foregroundStyle(Color(UIColor.fontColor(forBackgroundColor: UIColor(userPreferences.backgroundColors.first ?? Color.clear))))
        Spacer()
    }
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
            ForEach(refinedThemes) { theme in
                themeView(theme: theme).contextMenu {
                    Button("Apply") {
                        userPreferences.applyTheme(theme)
                    }
                }
            }
        }
        .padding()
    }
    
    @ViewBuilder
    func themeView(theme: Theme) -> some View {
        ZStack {
            // Larger square
            RoundedRectangle(cornerRadius: 15)
                .fill(LinearGradient(gradient: Gradient(colors: [theme.topColor, theme.bottomColor]), startPoint: .top, endPoint: .bottom))
                .frame(width: 150, height: 150)  // Entire square block
            
            VStack(alignment: .leading, spacing: 8) {
                
                // Small cube for entry background
                RoundedRectangle(cornerRadius: 10)
                    .fill(theme.entryBackgroundColor)
                    .frame(width: 130, height: 30)  // Adjusted to fit better within the square
                    .padding(.horizontal)
                    .overlay(
                        HStack(alignment: .center) {
                            Text(theme.name)
                                .foregroundStyle(Color(UIColor.fontColor(forBackgroundColor: UIColor.blendedColor(from: UIColor(theme.topColor), with: UIColor(theme.entryBackgroundColor)), colorScheme: colorScheme)))
                                .font(.custom(theme.fontName, size: theme.fontSize))

                        }
                    )
                
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(theme.accentColor)
                            .frame(width: 10, height: 10)
                        Text("accent")
                    }
                    
                    HStack(spacing: 8) {
                        Image(systemName: "pin.fill").resizable()
                            .foregroundStyle(theme.pinColor)
                            .frame(width: 10, height: 10)
                        Text("pin")
                    }
                    
                    HStack(spacing: 8) {
                        Image(systemName: "bell.fill").resizable()
                            .foregroundStyle(theme.reminderColor)
                            .frame(width: 10, height: 10)
                        Text("reminder")
                    }
                }
                .font(.custom(theme.fontName, size: theme.fontSize))
                .padding(.horizontal)
            }
        }
        .cornerRadius(20)  // Rounded corners for the entire block
        .shadow(color: Color(UIColor.fontColor(forBackgroundColor: UIColor.blendedColor(from: UIColor(userPreferences.backgroundColors.first ?? Color.clear), with: UIColor(userPreferences.backgroundColors[1])))).opacity(0.08), radius: 3)
        
    }
}


extension UserPreferences {
    func applyTheme(_ theme: Theme) {
           self.accentColor = theme.accentColor
           self.backgroundColors = [theme.topColor, theme.bottomColor]
           self.entryBackgroundColor = theme.entryBackgroundColor
           self.pinColor = theme.pinColor
           self.reminderColor = theme.reminderColor
           self.fontName = theme.fontName
           self.fontSize = theme.fontSize
           self.lineSpacing = theme.lineSpacing
       }
}



extension ThemeSheet {
    private func createShareURL(for userTheme: UserTheme) async -> URL? {
        guard let fileName = userTheme.name else { return nil }
        return await createThemePackage(userTheme: userTheme, fileName: fileName)
    }

    
    func shareTheme(_ userTheme: UserTheme) async {
        guard let url = await createShareURL(for: userTheme) else {
            print("Failed to create share URL for theme")
            return
        }
        
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        
        // For iPad support
        if let popoverController = activityVC.popoverPresentationController {
            popoverController.sourceView = UIApplication.shared.windows.first?.rootViewController?.view
            popoverController.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        DispatchQueue.main.async {
            UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
        }
    }
    
    private func handleImport(result: Result<[URL], Error>) {
          switch result {
          case .success(let urls):
              guard let url = urls.first else { return }
              if let importedTheme = importThemePackage(url: url) {
                  print("Imported theme: \(importedTheme)")
                  importedTheme.id = UUID()
                  coreDataManager.viewContext.insert(importedTheme)
                  
                  do {
                      try coreDataManager.viewContext.save()
                  } catch {
                      print("Failed to save imported theme: \(error.localizedDescription)")
                  }
              }
          case .failure(let error):
              print("Failed to import theme: \(error.localizedDescription)")
          }
      }
    
    func saveThemeAsJSON(userTheme: UserTheme) -> Data? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        return try? encoder.encode(userTheme)
    }
    
    
    func createThumbnailImage(userTheme: UserTheme) async -> UIImage? {
        return await renderThemeThumbnail(theme: userTheme.toTheme(), size: CGSize(width: 100, height: 100), scale: 2)
//        let size = CGSize(width: 100, height: 100)
//        let renderer = UIGraphicsImageRenderer(size: size)
//
//        let currentIcon = UIImage(named: userPreferences.activeAppIcon)
//        
//        return renderer.image { context in
//            // Draw a rounded rectangle as background
//            let roundedRect = CGRect(origin: .zero, size: size)
//            UIBezierPath(roundedRect: roundedRect, cornerRadius: 10).addClip()
//            
//            if let icon = currentIcon {
//                // Draw the app icon if it exists
//                icon.draw(in: roundedRect)
//            } else {
//                print("Failed to load app icon image, using fallback image")
//                
//                // Draw a fallback image (e.g., a plain color with text)
//                context.cgContext.setFillColor(UIColor.lightGray.cgColor)
//                context.fill(roundedRect)
//                
//                let fallbackText = "App Icon"
//                let attributes: [NSAttributedString.Key: Any] = [
//                    .font: UIFont.systemFont(ofSize: 16),
//                    .foregroundColor: UIColor.darkGray
//                ]
//                let textSize = fallbackText.size(withAttributes: attributes)
//                let textRect = CGRect(
//                    x: (size.width - textSize.width) / 2,
//                    y: (size.height - textSize.height) / 2,
//                    width: textSize.width,
//                    height: textSize.height
//                )
//                fallbackText.draw(in: textRect, withAttributes: attributes)
//            }
//            
//            // Optionally, you can add a color overlay to represent the theme
//            if let topColor = userTheme.topColor {
//                context.cgContext.setFillColor(topColor.withAlphaComponent(0.3).cgColor)
//                context.fill(roundedRect)
//            }
//        }
    }


    func createThemePackage(userTheme: UserTheme, fileName: String) async -> URL? {
        guard let themeData = saveThemeAsJSON(userTheme: userTheme),
                let thumbnailImage = await createThumbnailImage(userTheme: userTheme),
                let thumbnailData = thumbnailImage.pngData() else {
              print("Failed to create theme data or thumbnail")
              return nil
          }
        let fileManager = FileManager.default
        let tempDirectory = fileManager.temporaryDirectory
        let themeDirectory = tempDirectory.appendingPathComponent("\(userTheme.name) - \(formattedDate(Date()))")

        do {
            try fileManager.createDirectory(at: themeDirectory, withIntermediateDirectories: true, attributes: nil)

            let jsonFileURL = themeDirectory.appendingPathComponent("theme.json")
            let thumbnailFileURL = themeDirectory.appendingPathComponent("thumbnail.png")

            try themeData.write(to: jsonFileURL)
            try thumbnailData.write(to: thumbnailFileURL)

            print("theme.json created at \(jsonFileURL.path)")
            print("thumbnail.png created at \(thumbnailFileURL.path)")

            // Generate a unique file name by appending a UUID
            let uniqueFileName = "\(fileName)-\(UUID().uuidString).themePkg"
            let themePackageURL = tempDirectory.appendingPathComponent(uniqueFileName)

            try fileManager.zipItem(at: themeDirectory, to: themePackageURL)

            print("Theme package created at \(themePackageURL.path)")

            return themePackageURL
        } catch {
            print("Failed to create theme package: \(error.localizedDescription)")
            return nil
        }
    }

    func importThemePackage(url: URL) -> UserTheme? {
        printContentsOfTmpDirectory()
           clearTempDirectory()
           printContentsOfTmpDirectory()

           guard url.startAccessingSecurityScopedResource() else {
               print("Failed to access security-scoped resource")
               return nil
           }
           defer { url.stopAccessingSecurityScopedResource() }

           let fileManager = FileManager.default
           let tempDirectory = fileManager.temporaryDirectory
           let uniqueFileName = UUID().uuidString + "-" + url.lastPathComponent
           let tempFileURL = tempDirectory.appendingPathComponent(uniqueFileName)
           let extractionURL = tempDirectory.appendingPathComponent(UUID().uuidString)

           do {
               try fileManager.copyItem(at: url, to: tempFileURL)
               try fileManager.unzipItem(at: tempFileURL, to: extractionURL)

               let unzippedContents = try fileManager.contentsOfDirectory(atPath: extractionURL.path)
               print("Unzipped contents: \(unzippedContents)")

               var jsonFileURL: URL?
               for item in unzippedContents {
                   let itemPath = extractionURL.appendingPathComponent(item)
                   if fileManager.fileExists(atPath: itemPath.appendingPathComponent("theme.json").path) {
                       jsonFileURL = itemPath.appendingPathComponent("theme.json")
                       break
                   } else if itemPath.lastPathComponent == "theme.json" {
                       jsonFileURL = itemPath
                       break
                   }
               }

               guard let jsonFileURL = jsonFileURL else {
                   print("Failed to find theme.json in the unzipped contents.")
                   return nil
               }

               print("Looking for theme.json at \(jsonFileURL.path)")
               let themeData = try Data(contentsOf: jsonFileURL)
               
               // Print the contents of the JSON file for debugging
               if let jsonString = String(data: themeData, encoding: .utf8) {
                   print("Contents of theme.json:")
                   print(jsonString)
               }

               let decoder = JSONDecoder()
               decoder.userInfo[CodingUserInfoKey.managedObjectContext] = coreDataManager.viewContext

               do {
                   let userTheme = try decoder.decode(UserTheme.self, from: themeData)
                   return userTheme
               } catch let decodingError as DecodingError {
                   switch decodingError {
                   case .keyNotFound(let key, let context):
                       print("Key '\(key.stringValue)' not found: \(context.debugDescription)")
                       print("CodingPath: \(context.codingPath)")
                   case .valueNotFound(let type, let context):
                       print("Value of type '\(type)' not found: \(context.debugDescription)")
                       print("CodingPath: \(context.codingPath)")
                   case .typeMismatch(let type, let context):
                       print("Type mismatch for type '\(type)': \(context.debugDescription)")
                       print("CodingPath: \(context.codingPath)")
                   case .dataCorrupted(let context):
                       print("Data corrupted: \(context.debugDescription)")
                       print("CodingPath: \(context.codingPath)")
                   @unknown default:
                       print("Unknown decoding error: \(decodingError.localizedDescription)")
                   }
                   return nil
               }

           } catch {
               print("Failed to import theme package: \(error.localizedDescription)")
               if let nsError = error as NSError? {
                   print("Error domain: \(nsError.domain), code: \(nsError.code)")
                   print("Underlying error: \(nsError.userInfo[NSUnderlyingErrorKey] ?? "None")")
               }
               return nil
           }
       }

}


