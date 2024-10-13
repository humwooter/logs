//
//  CustomMultiDatePicker.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 4/13/24.
//
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
    let dateStringManager = DateStrings()
    @State private var dragOffset: CGFloat = 0

    @State private var currentMonth: Date
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var userPreferences: UserPreferences
    @State private var offset = CGSize.zero
    @State private var showingDatePicker = false  // State to toggle DatePicker visibility
    @State var calendar_item_dimension = UIScreen.main.bounds.width / 10

    init(datesModel: DatesModel, selectionColor: Color, backgroundColor: Color) {
        self.datesModel = datesModel
        self.selectionColor = selectionColor
        self.backgroundColor = backgroundColor
        _currentMonth = State(initialValue: Calendar.current.startOfMonth(for: Date()))
    }
    
    @State private var isIpad = UIDevice.current.userInterfaceIdiom == .pad

    var body: some View {
        VStack {
            monthHeaderView()
            if !showingDatePicker {
                weekDaysHeader()
                daysGridView().onAppear {
                    calendar_item_dimension = UIScreen.main.bounds.width / 10
                }
            } else {
                DatePicker(
                    "",
                    selection: $currentMonth,
                    displayedComponents: [.date]  // Adjust if you only want the month and year
                )
                .datePickerStyle(.wheel)
            }
        }
    }
    
    private func monthHeaderView() -> some View {
        HStack {
            Image(systemName: "chevron.left").foregroundColor(selectionColor)
                .onTapGesture {
                    shiftMonth(value: -1)
                }
            
            Spacer()
            Text("\(currentMonth, formatter: dateFormatter)")
                .font(.customHeadline)
                .foregroundStyle(getTextColor())
                .onTapGesture {
                    withAnimation {
                        showingDatePicker.toggle()
                    }
                }
            
            Spacer()
            
            Image(systemName: "chevron.right").foregroundColor(selectionColor)
                .onTapGesture {
                    shiftMonth(value: 1)
                }
        }
        .font(.customHeadline)
    }

    private func weekDaysHeader() -> some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 8) {
            // Insert padding items for the first row if necessary
            ForEach(["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"], id: \.self) { day in
                Text(day)
                    .font(.customHeadline)
                    .padding(.vertical, 5)
                    .foregroundStyle(getTextColor().opacity(0.3))
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
            }
            // Now insert actual day items
            ForEach(daysInMonth, id: \.self) { day in
                if let dayDate = Calendar.current.date(from: day) {
                    let formattedDate = datesModel.dateFormatter.string(from: dayDate)
                    let isSelected = datesModel.isDateSelected(dayDate)
                    dayButton(day, isSelected: isSelected, formattedDate: formattedDate)
                } else {
                    dayButton(day, isSelected: false, formattedDate: nil)
                }
            }
        }
        .offset(x: dragOffset)
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragOffset = value.translation.width
                }
                .onEnded { value in
                    let dayWidth = UIScreen.main.bounds.width / 7
                    withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.7, blendDuration: 0.3)) {
                        if value.translation.width > dayWidth / 2 {
                            shiftMonth(value: -1)
                        } else if value.translation.width < -dayWidth / 2 {
                            shiftMonth(value: 1)
                        }
                        dragOffset = 0
                    }
                    provideHapticFeedback()
                }
        )
    }

    @ViewBuilder
    func dayButton(_ day: DateComponents, isSelected: Bool, formattedDate: String?) -> some View {
        let calendarButton_dim: CGFloat = isIpad ? 55 : 35
        
        if let formattedDate = formattedDate,
           let monthDates = dateStringManager.dates(forMonthYear: dateStringManager.monthYear(from: formattedDate)!) {
            let dayString = formattedDate
            let unselectedColor = (formattedDate != nil && monthDates.contains(formattedDate) == true && !isSelected) ? selectionColor.opacity(0.2) : Color.clear
            Text("\(day.day!)")
                .font(.customHeadline)
                .frame(width: CGSize.calendarButtonWidth, height: CGSize.calendarButtonWidth)
                .background(isSelected ? selectionColor : unselectedColor)
                .foregroundStyle(isSelected ? Color(UIColor.fontColor(forBackgroundColor: UIColor(selectionColor))) : getTextColor())

                .cornerRadius(100)
            
                .onTapGesture {
                    if datesModel.doesDateExist(dayDate: day) {
                        datesModel.toggleDateSelection(dayDate: day)
                    } else {
                        datesModel.addDate(dayDate: day, isSelected: true)
                    }
                }

        } else {
            Text("\(day.day!)")
                .font(.customHeadline)
                .opacity(0.5)
                .frame(width: CGSize.calendarButtonWidth, height: CGSize.calendarButtonWidth)
                .background(backgroundColor)
                .foregroundStyle(isSelected ? Color(UIColor.fontColor(forBackgroundColor: UIColor(selectionColor))) : getTextColor())
                .cornerRadius(100)
        }
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
    
    func getTextColor() -> Color {
        let background1 = userPreferences.backgroundColors.first ?? Color.clear
        let background2 = userPreferences.backgroundColors[1]
        let entryBackground = userPreferences.entryBackgroundColor
        
        return calculateTextColor(
            basedOn: background1,
            background2: background2,
            entryBackground: entryBackground,
            colorScheme: colorScheme
        )
    }
}

// Extensions and supporting functions
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

// Extend DatesModel with new helper methods for toggling and adding dates
extension DatesModel {
    func doesDateExist(dayDate: DateComponents) -> Bool {
        if let date = calendar.date(from: dayDate) {
            let formattedDate = dateFormatter.string(from: date)
            return dates[formattedDate] != nil
        }
        return false
    }
    
    func toggleDateSelection(dayDate: DateComponents) {
        if let date = calendar.date(from: dayDate) {
            let formattedDate = dateFormatter.string(from: date)
            dates[formattedDate]?.isSelected.toggle()
        }
    }
    
    func addDate(dayDate: DateComponents, isSelected: Bool) {
        if let date = calendar.date(from: dayDate) {
            let formattedDate = dateFormatter.string(from: date)
            dates[formattedDate] = LogDate(date: dayDate, isSelected: isSelected)
        }
    }
}
