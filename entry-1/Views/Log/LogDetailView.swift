//
//  LogDetailView.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 10/27/23.
//

import Foundation
import SwiftUI
import CoreData
import UniformTypeIdentifiers



struct LogDetailView: View {
    @EnvironmentObject var coreDataManager: CoreDataManager
    @EnvironmentObject var userPreferences: UserPreferences
    @Environment(\.colorScheme) var colorScheme
    
    let log: Log
    
    var body: some View {
        if let entries = log.relationship as? Set<Entry>, !entries.isEmpty {
            Section {
                List(entries.sorted(by: { $0.time > $1.time }), id: \.self) { entry in
                    EntryDetailView(entry: entry)
                        .environmentObject(coreDataManager)
                        .environmentObject(userPreferences)
                
                    
                }
                .onAppear(perform: {
                    print("LOG detailz: \(log)")
                })
                // List(entries.sorted(by: { $0.time > $1.time }), id: \.self) { entry in
                //     VStack(alignment: .leading, spacing: 5) {
                //         HStack {
                //             VStack(alignment: .leading) {
                //                 HStack {
                //                     Text(formattedTime(time: entry.time))
                //                         .font(.footnote)
                //                         .foregroundColor(.gray)
                //                     Spacer()
                //                     if (entry.buttons.filter{$0}.count > 0 ) {
                //                         Image(systemName: entry.image).tag(entry.image)
                //                             .frame(width: 15, height: 15)
                //                             .foregroundColor(UIColor.backgroundColor(entry: entry, colorScheme: colorScheme))
                //                         //                                        .foregroundStyle(.red, .green, .blue, .purple)
                //                     }
                
                //                 }
                //                 Text(entry.content)
                //                     .fontWeight(entry.buttons.filter{$0}.count > 0 ? .bold : .regular)
                //                     .foregroundColor(colorScheme == .dark ? .white : .black)
                //                     .contextMenu {
                
                //                         Button(action: {
                //                             UIPasteboard.general.string = entry.content ?? ""
                //                         }) {
                //                             Text("Copy Message")
                //                             Image(systemName: "doc.on.doc")
                //                         }
                //                     }
                //             }
                //             Spacer() // Push the image to the right
                
                //         }
                
                
                
                //         if entry.imageContent != "" {
                //             if let filename = entry.imageContent {
                //                 let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                //                 let fileURL = documentsDirectory.appendingPathComponent(filename)
                //                 let data = try? Data(contentsOf: fileURL)
                
                
                //                 if let data = data, isGIF(data: data) {
                
                //                     let imageView = AnimatedImageView(url: fileURL)
                
                //                     let asyncImage = UIImage(data: data)
                
                //                     let height = asyncImage!.size.height
                
                //                     AnimatedImageView(url: fileURL).scaledToFit()
                
                
                //                     // Add imageView
                //                 } else {
                //                     if imageExists(at: fileURL) {
                //                         CustomAsyncImageView(url: fileURL).scaledToFit()
                //                     }
                
                //                     //                                AsyncImage(url: fileURL) { image in
                //                     //                                    image.resizable()
                //                     //                                        .scaledToFit()
                //                     //                                }
                //                     //                            placeholder: {
                //                     //                                ProgressView()
                //                     //                            }
                //                 }
                //             }
                //         }
                //     }
                //     //                .listRowBackground(backgroundColor(entry: entry))
                // }
                .listStyle(.automatic)
            }
            
            
            .navigationBarTitleDisplayMode(.inline)
        } else {
            Text("No entries available")
                .foregroundColor(.gray)
        }
    }
    


    
    //    func formattedTime(_ date: Date) -> String {
    //        let formatter = DateFormatter()
    //        formatter.timeStyle = .short
    //        return formatter.string(from: date)
    //    }
    
}
