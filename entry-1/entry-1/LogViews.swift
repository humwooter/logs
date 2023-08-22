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
                                if (entry.buttons.filter{$0}.count > 0 ) {
                                    Image(systemName: entry.image).tag(entry.image)
                                        .frame(width: 15, height: 15)
                                        .foregroundColor(backgroundColor(entry: entry))
//                                        .foregroundStyle(.red, .green, .blue, .purple)
                                }
                                
                            }
                            Text(entry.content)
                                .fontWeight(entry.buttons.filter{$0}.count > 0 ? .bold : .regular)
                            //    .foregroundColor(foregroundColor(entry: entry, background: UIColor(backgroundColor(entry: entry))))
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                        }
                        Spacer() // Push the image to the right
        
                    }
                    if let imageData = entry.imageContent {
                      if let image = UIImage(data: imageData) {
                        Image(uiImage: image)
                          .resizable()
                          .scaledToFit()
                      }
                    }
                }
//                .listRowBackground(backgroundColor(entry: entry))
            }
            .listStyle(.automatic)

            .navigationBarTitleDisplayMode(.inline)
        } else {
            Text("No entries available")
                .foregroundColor(.gray)
        }
    }
    private func foregroundColor(entry: Entry, background: UIColor) -> Color {
        let color = colorScheme == .dark ? Color.white : Color.black
        if (entry.buttons.filter{$0}.count == 0) { //not marked
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

//    private func backgroundColor(entry: Entry) -> Color {
//        let color: UIColor
//        let opacity_val = colorScheme == .dark ? 0.95 : 0.75
//        if entry.buttons[0] {
//            color = UIColor(userPreferences.selectedColors[0])
//            entry.color = UIColor(Color(color).opacity(opacity_val))
//        } else if entry.buttons[1] {
//            color = UIColor(userPreferences.selectedColors[1])
//            entry.color = UIColor(Color(color).opacity(opacity_val))
//        } else if entry.buttons[2] {
//            color = UIColor(userPreferences.selectedColors[2])
//            entry.color = UIColor(Color(color).opacity(opacity_val))
//        } else {
//            color = colorScheme == .dark ? UIColor.secondarySystemBackground : UIColor.tertiarySystemBackground
//            entry.color = colorScheme == .dark ? UIColor(Color.white) : UIColor(Color.black)
//            return Color(color)
//        }
//        return Color(entry.color)
//    }
    private func backgroundColor(entry: Entry) -> Color {
        let opacity_val = colorScheme == .dark ? 0.95 : 0.75

        for index in 0..<entry.buttons.count {
            if entry.buttons[index] {
//                let color = UIColor(userPreferences.selectedColors[index])
//                entry.color = UIColor(Color(color).opacity(opacity_val))
                if (entry.color == nil) {
                    entry.color = UIColor(userPreferences.selectedColors[index])
                }
                return Color(entry.color)
            }
        }

        let color = colorScheme == .dark ? UIColor.secondarySystemBackground : UIColor.tertiarySystemBackground
        entry.color = colorScheme == .dark ? UIColor(Color.white) : UIColor(Color.black)
        return Color(color)
    }

}
