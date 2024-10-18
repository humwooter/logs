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
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.colorScheme) var colorScheme

    @FetchRequest(
        entity: UserTheme.entity(),
        sortDescriptors: []
    ) var savedThemes: FetchedResults<UserTheme>
    
    @State var selectedTheme: UserTheme?
    @State private var editTheme = false
    @State private var editCurrentTheme = false
    @State private var showDocumentPicker = false

    private var isEditThemeActive: Binding<Bool> {
        Binding<Bool>(
            get: {
                selectedTheme != nil && editTheme
            },
            set: { newValue in
                if !newValue {
                    editTheme = false
                    selectedTheme = nil
                }
            }
        )
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let columnsCount = screenWidth > 600 ? 3 : 2  // Adjust based on width
        
            ScrollView {
                customThemesView(columnsCount: columnsCount)
                defaultThemesView(columnsCount: columnsCount)
            }
            .background {
                userPreferences.backgroundView(colorScheme: colorScheme)
            }
            .scrollContentBackground(.hidden)
            .navigationBarTitleTextColor(Color(UIColor.fontColor(forBackgroundColor: UIColor(userPreferences.backgroundColors.first ?? Color.clear), colorScheme: colorScheme)))
            .font(.custom(String(userPreferences.fontName), size: CGFloat(Float(userPreferences.fontSize))))
            .accentColor(userPreferences.accentColor)
            .sheet(isPresented: isEditThemeActive) {
                EditUserThemeView(userTheme: $selectedTheme)
                    .environmentObject(coreDataManager)
                    .environmentObject(userPreferences)
                    .accentColor(userPreferences.accentColor)

            }
            .sheet(isPresented: $editCurrentTheme) {
                CurrentThemeEditView()
                    .environmentObject(userPreferences)
                    .accentColor(userPreferences.accentColor)

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
    }

    @ViewBuilder
    func currentThemeView() -> some View {
        let currentTheme = Theme(
            name: userPreferences.themeName,
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
        themeView(theme: currentTheme, userTheme: nil, isCurrentTheme: true)
        .contextMenu {
            Button {
                editCurrentTheme = true
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            
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
    func customThemesView(columnsCount: Int) -> some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: columnsCount), spacing: 20) {
            currentThemeView()
            ForEach(savedThemes, id: \.id) { userTheme in
                let theme = userTheme.toTheme()
                themeView(theme: theme, userTheme: userTheme, isCurrentTheme: false)

            }.onAppear {
                print("ALL SAVED THEMES")
                print(savedThemes)
            }
        }
        .padding()
    }

    @ViewBuilder
    func defaultThemesView(columnsCount: Int) -> some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: columnsCount), spacing: 20) {
            ForEach(refinedThemes) { theme in
                themeView(theme: theme, userTheme: nil, isCurrentTheme: false)
                    .contextMenu {
                        Button("Apply") {
                            userPreferences.applyTheme(theme)
                        }
                    }
            }
        }
        .padding()
    }
    
    
    @ViewBuilder
    func customThemesView() -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
            currentThemeView()
            ForEach(savedThemes, id: \.id) { userTheme in
                let theme = userTheme.toTheme()
                themeView(theme: theme, userTheme: userTheme, isCurrentTheme: false)

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
        let columnsCount = calculateColumns()
        
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: calculateColumns()), spacing: 20) {
            ForEach(refinedThemes) { theme in
                themeView(theme: theme, userTheme: nil, isCurrentTheme: false)
                    .contextMenu {
                        Button("Apply") {
                            userPreferences.applyTheme(theme)
                        }
                    }
            }
        }
        .padding()
    }

    func calculateColumns() -> Int {
        // Using UIScreen width to avoid layout issues caused by GeometryReader
        let screenWidth = UIScreen.main.bounds.width
        return screenWidth > 600 ? 3 : 2  // Adjust the threshold as needed
    }
    
    
    @ViewBuilder
    func themeDetailsButton(theme: Theme) -> some View {
        Button("Copy Theme Details to Clipboard") {
            let themeFormula = """
            Theme(
                name: "\(theme.name)",
                accentColor: Color(red: \(theme.accentColor.components.red), green: \(theme.accentColor.components.green), blue: \(theme.accentColor.components.blue)),
                topColor: Color(red: \(theme.topColor.components.red), green: \(theme.topColor.components.green), blue: \(theme.topColor.components.blue)),
                bottomColor: Color(red: \(theme.bottomColor.components.red), green: \(theme.bottomColor.components.green), blue: \(theme.bottomColor.components.blue)),
                entryBackgroundColor: Color(red: \(theme.entryBackgroundColor.components.red), green: \(theme.entryBackgroundColor.components.green), blue: \(theme.entryBackgroundColor.components.blue), opacity: \(theme.entryBackgroundColor.components.alpha)),
                pinColor: Color(red: \(theme.pinColor.components.red), green: \(theme.pinColor.components.green), blue: \(theme.pinColor.components.blue)),
                reminderColor: Color(red: \(theme.reminderColor.components.red), green: \(theme.reminderColor.components.green), blue: \(theme.reminderColor.components.blue)),
                fontName: "\(theme.fontName)",
                fontSize: \(theme.fontSize),
                lineSpacing: \(theme.lineSpacing)
            )
            """
            
            let themeDetails = """
            Theme Name: \(theme.name)
            
            Top Color: \(theme.topColor.description) (#\(theme.topColor.toHex()))
            Bottom Color: \(theme.bottomColor.description) (#\(theme.bottomColor.toHex()))
            Accent Color: \(theme.accentColor.description) (#\(theme.accentColor.toHex()))
            Entry Background Color: \(theme.entryBackgroundColor.description) (#\(theme.entryBackgroundColor.toHex()))
            Pin Color: \(theme.pinColor.description) (#\(theme.pinColor.toHex()))
            Reminder Color: \(theme.reminderColor.description) (#\(theme.reminderColor.toHex()))
            
            Font Name: \(theme.fontName)
            Font Size: \(theme.fontSize)
            Line Spacing: \(theme.lineSpacing)
            
            Swift Theme Formula:
            \(themeFormula)
            """
            
            // Copy the theme details to clipboard
            UIPasteboard.general.string = themeDetails
        }
    }


    
    @ViewBuilder func menuButtons(theme: Theme, userTheme: UserTheme?, isCurrentTheme: Bool) -> some View {
        
    
        if !isCurrentTheme {
            themeDetailsButton(theme: theme)

            Button {
                userPreferences.applyTheme(theme)
            } label: {
                Label("Apply", systemImage: "checkmark.circle")
            }
        }
        
        if let userTheme = userTheme {
            themeDetailsButton(theme: userTheme.toTheme())

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

        } else if isCurrentTheme {
            Button {
                editCurrentTheme = true
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            
            Button("Save") {
                let userTheme = UserTheme(context: coreDataManager.viewContext)
                userTheme.fromTheme(theme)
                do {
                    try coreDataManager.viewContext.save()
                } catch {
                    print("Failed to save theme: \(error.localizedDescription)")
                }
            }
        }
    }
    
 
    
    func themeView(theme: Theme, userTheme: UserTheme?, isCurrentTheme: Bool) -> some View {
        
        var label = ""
        var themeName = ""
        
        if isCurrentTheme {
            themeName = theme.name
            label = "current"
        } else if let userTheme = userTheme {
            themeName = userTheme.name ?? "unnamed"
          label = "custom"
        } else {
            themeName = theme.name
            label = "default"
        }
        
        return VStack {
   
            ZStack {
                // Larger square
                RoundedRectangle(cornerRadius: 15)
                    .fill(LinearGradient(gradient: Gradient(colors: getThemeBackground(topColor: theme.topColor, bottomColor: theme.bottomColor)), startPoint: .top, endPoint: .bottom))
                    .strokeBorder(calculateTextColor(basedOn: theme.topColor, background2: theme.bottomColor, entryBackground: theme.entryBackgroundColor, colorScheme: colorScheme).opacity(0.2))
                    .frame(CGSize.superLargeIconSize())  // Entire square block

                
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Menu {
                            menuButtons(theme: theme, userTheme: userTheme, isCurrentTheme: isCurrentTheme)
                        } label: {
                            VStack(alignment: .leading) {
                                HStack {
                                    Text(label).opacity(label == "current" ? 1 : 0.5)
                                    Spacer()
                                    Image(systemName: "ellipsis").bold()
                                }

                            }
                            .font(.customCaption)
                        }
                    }
                    .foregroundStyle(getBackgroundTextColor().opacity(0.8))
                    .padding(.horizontal)
                    Divider().padding(.horizontal)
                        .foregroundStyle(getBackgroundTextColor().opacity(0.8))

                    // Small cube for entry background
                    RoundedRectangle(cornerRadius: 10)
                        .fill(getEntryBackground(entryBackgroundColor: theme.entryBackgroundColor))
                        .frame(width: 0.8*CGSize.buttonWidth, height: CGSize.buttonWidth*0.2)
                        .padding(.horizontal)
                        .overlay(
                            HStack(alignment: .center) {
                                Text(theme.name)
                                    .foregroundStyle(calculateTextColor(basedOn: theme.topColor, background2: theme.bottomColor, entryBackground: theme.entryBackgroundColor, colorScheme: colorScheme))
                                    .font(.custom(theme.fontName, size: theme.fontSize))
                                
                            }
                        )
                    
                    
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(theme.accentColor)
                                .frame(width: 0.1*CGSize.smallButtonWidth, height: 0.13*CGSize.smallButtonWidth)
                            Text("accent")
                                .foregroundStyle(getBackgroundTextColor())

                        }
                        
                        HStack(spacing: 8) {
                            Image(systemName: "pin.fill").resizable()
                                .foregroundStyle(theme.pinColor)
                                .frame(width: 0.1*CGSize.smallButtonWidth, height: 0.13*CGSize.smallButtonWidth)
                            Text("pin")
                                .foregroundStyle(getBackgroundTextColor())
                        }
                        
                        HStack(spacing: 8) {
                            Image(systemName: "bell.fill").resizable()
                                .foregroundStyle(theme.reminderColor)
                                .frame(width: 0.1*CGSize.smallButtonWidth, height: 0.13*CGSize.smallButtonWidth)
                            Text("reminder")
                                .foregroundStyle(getBackgroundTextColor())

                        }
                    }
                    .font(.custom(theme.fontName, size: theme.fontSize))
                    .padding(.horizontal)
                    
//
                }
            }
            .frame(CGSize.superLargeIconSize())  // Entire square block
            .contextMenu {
                menuButtons(theme: theme, userTheme: userTheme, isCurrentTheme: isCurrentTheme)
            }
            
       
        }

//        .padding(.horizontal)
        
        func getBackgroundTextColor() -> Color {
            return Color(UIColor.fontColor(forBackgroundColor: UIColor.averageColor(of: UIColor(theme.topColor), and: UIColor(theme.bottomColor))))
        }
        
    }
    
    func getThemeBackground(topColor: Color, bottomColor: Color) -> [Color] {
        let blendedColor = UIColor.averageColor(of: UIColor(topColor), and: UIColor(bottomColor))
        if isClear(for: blendedColor) {
            return [getDefaultBackgroundColor(colorScheme: colorScheme)]
        } else { return [topColor, bottomColor] }

    }
    

}


extension UserPreferences {
    func applyTheme(_ theme: Theme) {
            self.themeName = theme.name
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

    func clearTempDirectory() {
        let fileManager = FileManager.default
        let tempDirectory = fileManager.temporaryDirectory

        do {
            let filePaths = try fileManager.contentsOfDirectory(at: tempDirectory, includingPropertiesForKeys: nil, options: [])
            for filePath in filePaths {
                try fileManager.removeItem(at: filePath)
                print("Deleted file at \(filePath)")
            }
        } catch {
            print("Failed to clear temp directory: \(error.localizedDescription)")
        }
    }


    func createThemePackage(userTheme: UserTheme, fileName: String) async -> URL? {
        
        clearTempDirectory()
        
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
            let uniqueFileName = "\(fileName).themePkg"
            let themePackageURL = tempDirectory.appendingPathComponent(uniqueFileName)

            try fileManager.zipItem(at: themeDirectory, to: themePackageURL)

            print("Theme package created at \(themePackageURL.path)")

            return themePackageURL
        } catch {
            print("Failed to create theme package: \(error.localizedDescription)")
            return nil
        }
    }

    func importThemePackage(url: URL) -> UserTheme? {//add comments
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
    
    func getIdealHeaderTextColor() -> Color {
        return Color(UIColor.fontColor(forBackgroundColor: UIColor.averageColor(of: UIColor(userPreferences.backgroundColors.first ?? Color.clear), and: UIColor(userPreferences.backgroundColors[1])), colorScheme: colorScheme))
    }
    
    func getEntryBackground(entryBackgroundColor: Color) -> Color {
        if isClear(for: UIColor(entryBackgroundColor)) {
            return getDefaultEntryBackgroundColor(colorScheme: colorScheme)
        } else {
            return entryBackgroundColor
        }
    }

}

