//
//  LogViews.swift
//  entry-1
//
//  Created by Katya Raman on 8/14/23.
//
//

import Foundation
import SwiftUI
import CoreData

struct LogsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var userPreferences: UserPreferences

    @FetchRequest(
        entity: Log.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Log.day, ascending: true)]
    ) var logs: FetchedResults<Log>

    var body: some View {
        NavigationView {
            List(logs, id: \.self) { log in
                NavigationLink(destination: LogDetailView(log: log).environmentObject(userPreferences)) {
                    Text(log.day)
                }
            }
            .navigationTitle("Logs")
        }
    }
}

//struct LogDetailView: View {
//    @Environment(\.managedObjectContext) private var viewContext
//    @EnvironmentObject var userPreferences: UserPreferences
//    @Environment(\.colorScheme) var colorScheme
//
//
//    let log: Log
//
//    var body: some View {
//        if let entries = log.relationship as? Set<Entry>, !entries.isEmpty {
//            List(entries.sorted(by: { $0.time > $1.time }), id: \.self) { entry in
//                VStack(alignment: .leading, spacing: 5) {
//                    Text(formattedTime(entry.time))
//                        .font(.footnote)
//                        .foregroundColor(.gray)
//                    Text(entry.content)
//                        .fontWeight(entry.isButton1 || entry.isButton2 || entry.isButton3 ? .bold : .regular) // Bold if important
////                        .foregroundColor(entry.color != nil ? Color(entry.color) : Color.white)
//                        .foregroundColor(foregroundColor(entry: entry, background: UIColor(backgroundColor(entry: entry)))) // Yellow if important
////                        .foregroundColor(Color(entry.color))
//                }
//                .listRowBackground(backgroundColor(entry: entry))
//            }
//            .listStyle(.plain)
//            .navigationBarTitleDisplayMode(.inline)
//        } else {
//            Text("No entries available")
//                .foregroundColor(.gray)
//        }
//    }
//
//    func formattedTime(_ date: Date) -> String {
//        let formatter = DateFormatter()
//        formatter.timeStyle = .short
//        return formatter.string(from: date)
//    }
//
//    private func backgroundColor(entry: Entry) -> Color {
//        let color: UIColor
//        let opacity_val = colorScheme == .dark ? 0.95 : 0.75
//        if entry.isButton1 {
//            color = UIColor(userPreferences.buttonColor1)
//            entry.color = UIColor(Color(color).opacity(opacity_val))
//        } else if entry.isButton2 {
//            color = UIColor(userPreferences.buttonColor2)
//            entry.color = UIColor(Color(color).opacity(opacity_val))
//        } else if entry.isButton3 {
//            color = UIColor(userPreferences.buttonColor3)
//            entry.color = UIColor(Color(color).opacity(opacity_val))
//        } else {
//            color = colorScheme == .dark ? UIColor.secondarySystemBackground : UIColor.tertiarySystemBackground
//            entry.color = colorScheme == .dark ? UIColor(Color.white) : UIColor(Color.black)
//            return Color(color)
//        }
//        return Color(entry.color)
//    }
//
//
////    private func foregroundColor(entry: Entry) -> UIColor {
//////        print("entry.color: ", entry.color)
////        if (entry.color == nil) {
////            let color = colorScheme == .dark ? UIColor(Color.white) : UIColor(Color.black)
////            return color
////        }
////        return entry.color
////    }
//    private func foregroundColor(entry: Entry, background: UIColor) -> Color {
//        let color = colorScheme == .dark ? Color.white : Color.black
//        if (!entry.isButton1 && !entry.isButton2 && !entry.isButton3) { //not marked
//            return color
//        }
//        var red: CGFloat = 0
//        var green: CGFloat = 0
//        var blue: CGFloat = 0
//        var alpha: CGFloat = 0
//
//        background.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
//
//        let brightness = (red * 299 + green * 587 + blue * 114) / 1000
//
//        return brightness > 0.5 ? Color.black : Color.white
//    }
////    private func foregroundColor(entry: Entry) -> Color {
////        if entry.isButton1 {
////            return userPreferences.buttonColor1
////        }
////        else if entry.isButton2 {
////            return userPreferences.buttonColor2
////        }
////        else if entry.isButton3 {
////            return userPreferences.buttonColor3
////        }
////        else {
////            return .primary
////        }
////    }
//}






struct LogDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var userPreferences: UserPreferences
    @Environment(\.colorScheme) var colorScheme

    let log: Log

    var body: some View {
        if let entries = log.relationship as? Set<Entry>, !entries.isEmpty {
            List(entries.sorted(by: { $0.time > $1.time }), id: \.self) { entry in
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        VStack(alignment: .leading) {
                            HStack {
                                Text(formattedTime(entry.time))
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                                Spacer()
                                if (entry.image != nil ) {
//                                    Image(systemName: entry.image)
                                    Image(systemName: entry.image).tag(entry.image)
//                                        .resizable()
                                        .frame(width: 15, height: 15)
                                        .foregroundColor(backgroundColor(entry: entry))
                                }
                                
//                                if entry.isButton1 {
//                                    Image(systemName: userPreferences.image1)
//                                        .resizable()
//                                        .frame(width: 15, height: 15)
////                                        .foregroundColor(foregroundColor(entry: entry, background: UIColor(backgroundColor(entry: entry))))
//                                        .foregroundColor(backgroundColor(entry: entry))
//                                } else if entry.isButton2 {
//                                    Image(systemName: userPreferences.image2)
//                                        .resizable()
//                                        .frame(width: 15, height: 15)
////                                        .foregroundColor(foregroundColor(entry: entry, background: UIColor(backgroundColor(entry: entry))))
//                                        .foregroundColor(backgroundColor(entry: entry))
//                                } else if entry.isButton3 {
//                                    Image(systemName: userPreferences.image3)
//                                        .resizable()
//                                        .frame(width: 15, height: 15)
////                                        .foregroundColor(foregroundColor(entry: entry, background: UIColor(backgroundColor(entry: entry))))
//                                        .foregroundColor(backgroundColor(entry: entry))
//                                }
                            }
                            Text(entry.content)
                                .fontWeight(entry.isButton1 || entry.isButton2 || entry.isButton3 ? .bold : .regular)
//                                .foregroundColor(foregroundColor(entry: entry, background: UIColor(backgroundColor(entry: entry))))
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                        }
                        Spacer() // Push the image to the right
                        
//                        if entry.isButton1 {
//                            Image(systemName: userPreferences.image1)
//                                .resizable()
//                                .frame(width: 15, height: 15)
//                        } else if entry.isButton2 {
//                            Image(systemName: userPreferences.image2)
//                                .resizable()
//                                .frame(width: 15, height: 15)
//                        } else if entry.isButton3 {
//                            Image(systemName: userPreferences.image3)
//                                .resizable()
//                                .frame(width: 15, height: 15)
//                        }
        
                    }
                }
//                .listRowBackground(backgroundColor(entry: entry))
            }
//            .listStyle(.insetGrouped)
            .listStyle(.automatic)

            .navigationBarTitleDisplayMode(.inline)
        } else {
            Text("No entries available")
                .foregroundColor(.gray)
        }
    }
    private func foregroundColor(entry: Entry, background: UIColor) -> Color {
        let color = colorScheme == .dark ? Color.white : Color.black
        if (!entry.isButton1 && !entry.isButton2 && !entry.isButton3) { //not marked
            return color
        }
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        background.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        let brightness = (red * 299 + green * 587 + blue * 114) / 1000

        return brightness > 0.5 ? Color.black : Color.white
    }
    func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func backgroundColor(entry: Entry) -> Color {
        let color: UIColor
        let opacity_val = colorScheme == .dark ? 0.95 : 0.75
        if entry.isButton1 {
            color = UIColor(userPreferences.buttonColor1)
            entry.color = UIColor(Color(color).opacity(opacity_val))
        } else if entry.isButton2 {
            color = UIColor(userPreferences.buttonColor2)
            entry.color = UIColor(Color(color).opacity(opacity_val))
        } else if entry.isButton3 {
            color = UIColor(userPreferences.buttonColor3)
            entry.color = UIColor(Color(color).opacity(opacity_val))
        } else {
            color = colorScheme == .dark ? UIColor.secondarySystemBackground : UIColor.tertiarySystemBackground
            entry.color = colorScheme == .dark ? UIColor(Color.white) : UIColor(Color.black)
            return Color(color)
        }
        return Color(entry.color)
    }
}
