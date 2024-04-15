//
//  CustomMultiDatePicker.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 4/13/24.
//

import Foundation
import SwiftUI
import UIKit


// Helper extensions to manage dates:
extension Date {
    var startOfMonth: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components)!
    }
}





struct CalendarView: View {
    @ObservedObject var datesModel: DatesModel
    let selectionColor: Color
    let backgroundColor: Color

    @State private var currentMonth: Date
    @Environment(\.colorScheme) var colorScheme
    @State private var offset = CGSize.zero
    @State private var showingDatePicker = false  // State to toggle DatePicker visibility

    
    init(datesModel: DatesModel, selectionColor: Color, backgroundColor: Color) {
        self.datesModel = datesModel
        self.selectionColor = selectionColor
        self.backgroundColor = backgroundColor
        _currentMonth = State(initialValue: Calendar.current.startOfMonth(for: Date()))
    }

    var body: some View {
        VStack {
            monthHeaderView()
            if !showingDatePicker {
                weekDaysHeader()
                daysGridView()
            } else {
                DatePicker(
                    "",
                    selection: $currentMonth,
                    displayedComponents: [.date]  // Adjust if you only want the month and year
                )
                .datePickerStyle(.wheel)
            }
        }
//        .gesture(DragGesture().onEnded(handleSwipe))
    }
    
    
    

    private func monthHeaderView() -> some View {
        HStack {
            Image(systemName: "chevron.left").foregroundColor(selectionColor)
                .onTapGesture {
                    shiftMonth(value: -1)
                }

            Spacer()

   
                       Text("\(currentMonth, formatter: dateFormatter)")
                           .font(.headline)
                           .foregroundColor(colorScheme == .dark ? .white : .black) // Adjusting color based on the theme
                           .onTapGesture {
                               withAnimation {
                                   showingDatePicker.toggle()
                               }
                           }//                   .sheet(isPresented: $showingDatePicker) {
//                       // DatePicker in a modal sheet
//                       datePickerSheet
//                   }

//            Text("\(currentMonth, formatter: dateFormatter)")
//                .font(.headline)

            Spacer()

            Image(systemName: "chevron.right").foregroundColor(selectionColor)
                .onTapGesture {
                    shiftMonth(value: 1)
                }
        }
        .font(.system(size: UIFont.systemFontSize + 3))
    }
    
//    private var datePickerSheet: some View {
//        NavigationView {
//            DatePicker(
//                "",
//                selection: $currentMonth,
//                displayedComponents: [.date]  // Adjust if you only want the month and year
//            )
//            .datePickerStyle(.wheel)
//            .padding()
//            .navigationTitle("Pick a Month")
//            .toolbar {
//                ToolbarItem(placement: .confirmationAction) {
//                    Button("Done") {
//                        showingDatePicker = false
//                    }
//                }
//            }
//        }
//    }


    private func weekDaysHeader() -> some View {
        HStack {
            ForEach(["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"], id: \.self) { day in
                Text(day).fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 5)
                    .foregroundStyle(Color(UIColor.fontColor(forBackgroundColor: UIColor(getDefaultEntryBackgroundColor(colorScheme: colorScheme)))).opacity(0.3))
            }.scaledToFit()
        }
    }
    
    @ViewBuilder
    private func daysGridView() -> some View {
        let daysInMonth = Calendar.current.generateDaysInMonth(for: currentMonth)
        let monthStart = Calendar.current.startOfMonth(for: currentMonth)
        let padding = Calendar.current.weekDayAndPadding(for: monthStart)
        
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 8) {
            // Insert padding items for the first row if necessary
            ForEach(0..<padding, id: \.self) { _ in
                Text("")
                    .frame(width: 35, height: 35) // Empty frame for padding
            }
            // Now insert actual day items
            ForEach(daysInMonth, id: \.self) { day in
                if let index = datesModel.dates.firstIndex(where: { $0.date == day }) {
                    let logDay = datesModel.dates[index]
                    dayButton(day, isSelected: logDay.isSelected)
                } else {
                    dayButton(day, isSelected: false)
                }
            }
        }
    }

    @ViewBuilder
    func dayButton(_ day: DateComponents, isSelected: Bool) -> some View {
        
        let dateStringManager = DateStrings()
        
        if let monthDates = dateStringManager.dates(forMonthYear: dateStringManager.monthYear(from: format(dateComponents: day)!)!) {
            
            let dayString = format(dateComponents: day)!
            if monthDates.contains(dayString) && !isSelected { //hasLog
                 Text("\(day.day!)").font(.system(size: UIFont.systemFontSize + 2))
                    .frame(width: 35, height: 35)
                    .background(selectionColor .opacity(0.3))
                    .foregroundStyle ( isSelected ? Color(UIColor.fontColor(forBackgroundColor: UIColor(selectionColor))) :
                                        Color(UIColor.fontColor(forBackgroundColor: UIColor(getDefaultEntryBackgroundColor(colorScheme: colorScheme)))))
                    .cornerRadius(35)
                    .onTapGesture {
                        if let index = datesModel.dates.firstIndex(where: { $0.date == day }) {
                            datesModel.dates[index].isSelected.toggle()
                        } else {
                            datesModel.dates.append(LogDate(date: day, isSelected: true))
                        }
                    }
            } else {
                 Text("\(day.day!)").font(.system(size: UIFont.systemFontSize + 2))
                    .frame(width: 35, height: 35)
                    .background(isSelected ? selectionColor : backgroundColor)
                    .foregroundStyle ( isSelected ? Color(UIColor.fontColor(forBackgroundColor: UIColor(selectionColor))) :
                                        Color(UIColor.fontColor(forBackgroundColor: UIColor(getDefaultEntryBackgroundColor(colorScheme: colorScheme)))))
                    .cornerRadius(35)
                    .onTapGesture {
                        if let index = datesModel.dates.firstIndex(where: { $0.date == day }) {
                            datesModel.dates[index].isSelected.toggle()
                        } else {
                            datesModel.dates.append(LogDate(date: day, isSelected: true))
                        }
                    }
            }
        } else {
            Text("\(day.day!)").font(.system(size: UIFont.systemFontSize + 2)).opacity(0.5)
               .frame(width: 35, height: 35)
               .background(backgroundColor)
               .foregroundStyle (Color(UIColor.fontColor(forBackgroundColor: UIColor(getDefaultEntryBackgroundColor(colorScheme: colorScheme)))))
               .cornerRadius(35)
        }
//        else {
//            return Text("Error")
//        }
    }
    
    func format(dateComponents: DateComponents) -> String? {
        // Ensure the date components include at least month, day, and year.
        guard let date = Calendar.current.date(from: dateComponents) else {
            print("Invalid date components")
            return nil
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"  // Set the date format
        return dateFormatter.string(from: date)
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }

    private func shiftMonth(value: Int) {
        if let newMonth = Calendar.current.date(byAdding: .month, value: value, to: currentMonth) {
            currentMonth = newMonth
        }
    }

//    private func handleSwipe(_ gesture: DragGesture.Value) {
//        let horizontalSwipe = gesture.translation.width
//        if horizontalSwipe > 50 {
//            withAnimation {
//                shiftMonth(value: -1)
//            }
//        } else if horizontalSwipe < -50 {
//            withAnimation {
//                shiftMonth(value: 1)
//            }
//        }
//    }
//    private func handleSwipe(_ gesture: DragGesture.Value) {
//           let horizontalSwipe = gesture.translation.width
//           if horizontalSwipe > 50 {
////               withAnimation(.easeOut) {
//                   offset = CGSize(width: 1000, height: 0)
//                   shiftMonth(value: -1)
////               }
//               offset = .zero // Reset offset after animation
//           } else if horizontalSwipe < -50 {
////               withAnimation(.easeOut) {
//                   offset = CGSize(width: -1000, height: 0)
//                   shiftMonth(value: 1)
////               }
//               offset = .zero // Reset offset after animation
//           }
//       }


//    private func toggleDaySelection(day: DateComponents) {
//        if datesModel.dates.contains(day) {
//            datesModel.dates.remove(day)
//        } else {
//            datesModel.dates.insert(day)
//        }
//    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: self.count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, self.count)])
        }
    }
}

extension Calendar {
    func generateDaysInMonth(for date: Date) -> [DateComponents] {
          let range = self.range(of: .day, in: .month, for: date)!
          let components = self.dateComponents([.year, .month], from: date)
          return range.compactMap { day -> DateComponents? in
              var newComponents = components
              newComponents.day = day
              return newComponents
          }
      }
    
    func startOfMonth(for date: Date) -> Date {
        let components = dateComponents([.year, .month], from: date)
        return self.date(from: components)!
    }
    
    func weekDayAndPadding(for firstDayOfMonth: Date) -> Int {
        let firstWeekDay = self.component(.weekday, from: firstDayOfMonth) // Gets the weekday index
        let padding = (firstWeekDay - self.firstWeekday + 7) % 7 // Calculate padding based on the calendar's first weekday
        return padding
    }
}
