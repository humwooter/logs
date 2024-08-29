//
//  WeeklyCalendariew.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 8/19/24.
//

import SwiftUI

struct ScrollableWeeklyCalendarView: View {
    @ObservedObject var datesModel: DatesModel
    let selectionColor: Color
    let backgroundColor: Color
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var userPreferences: UserPreferences

    @State private var currentPage: Int = 0
    @State private var dragOffset: CGFloat = 0
    @State private var showingDatePicker = false

    let dateStringManager = DateStrings()

    let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7) // 7 columns with spacing

    var body: some View {
        VStack {
            monthHeaderView()
            weekViewContainer()
//                .padding(.horizontal)
        }
        .padding(.vertical)
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private func monthHeaderView() -> some View {
        HStack {
            Image(systemName: "chevron.left")
                .font(.customHeadline)
                .onTapGesture {
                    vibration_light.impactOccurred()
                    shiftPage(value: -1)
                }
                .foregroundStyle(selectionColor)

            Spacer()

            VStack {
                            Text("\(monthName(for: currentPage))")
                                .font(.headline)
                                .foregroundStyle(getTextColor())
                                .onTapGesture {
                                    withAnimation {
                                        showingDatePicker.toggle()
                                    }
                                }
                            Text("\(weekRange(for: currentPage))")
                    .font(.customHeadline)
                                .foregroundStyle(getTextColor().opacity(0.5))
                        }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.customHeadline)
                .onTapGesture {
                    vibration_light.impactOccurred()
                    shiftPage(value: 1)
                }
                .foregroundStyle(selectionColor)
        }.frame(maxWidth: .infinity)
            .padding()
    }

    private func weekViewContainer() -> some View {
        VStack {
            weekdayHeaderView().padding(.bottom)
            LazyVGrid(columns: columns, spacing: 5) {
                ForEach(0..<7) { dayOffset in
                    if let date = Calendar.current.date(byAdding: .day, value: dayOffset, to: weekStart(for: currentPage)) {
                        let dayComponents = Calendar.current.dateComponents([.year, .month, .day, .weekday], from: date)
                        let formattedDate = datesModel.dateFormatter.string(from: date)
                        let isSelected = datesModel.isDateSelected(date)
                        dayButton(dayComponents, isSelected: isSelected, formattedDate: formattedDate)
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
                                currentPage -= 1
                            } else if value.translation.width < -dayWidth / 2 {
                                currentPage += 1
                            }
                            dragOffset = 0
                        }
                        provideHapticFeedback()
                    }
            )
        }
    }

    private func weekdayHeaderView() -> some View {
        LazyVGrid(columns: columns) {
            ForEach(["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"], id: \.self) { day in
                Text(day)
                    .font(.customHeadline)
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(getTextColor().opacity(0.3))
            }
        }
    }

    @ViewBuilder
    private func dayButton(_ day: DateComponents, isSelected: Bool, formattedDate: String) -> some View {
        let monthDates = dateStringManager.dates(forMonthYear: dateStringManager.monthYear(from: formattedDate)!)
        let unselectedColor = (formattedDate != nil && monthDates?.contains(formattedDate) == true && !isSelected) ? selectionColor.opacity(0.35) : Color.clear

        VStack {
            Text("\(day.day!)")
                .font(.customHeadline)
        }
        .frame(width: CGSize.calendarButtonWidth, height: CGSize.calendarButtonWidth)
        .background {
            Circle().fill(isSelected ? selectionColor : unselectedColor)
                .strokeBorder(unselectedColor.opacity(0.6), lineWidth: 1)
        }
        .clipShape(Circle())
        
        .foregroundStyle(isSelected ? Color(UIColor.fontColor(forBackgroundColor: UIColor(selectionColor))) : getTextColor())
        .onTapGesture {
            if datesModel.doesDateExist(dayDate: day) {
                datesModel.toggleDateSelection(dayDate: day)
            } else {
                datesModel.addDate(dayDate: day, isSelected: true)
            }
        }
    }

    private func weekStart(for pageOffset: Int) -> Date {
         let calendar = Calendar.current
         let currentWeekStart = calendar.startOfWeek(for: Date())
         return calendar.date(byAdding: .weekOfYear, value: pageOffset, to: currentWeekStart)!
     }

     private func weekEnd(for pageOffset: Int) -> Date {
         let calendar = Calendar.current
         let weekStart = self.weekStart(for: pageOffset)
         return calendar.date(byAdding: .day, value: 6, to: weekStart)!
     }

     private func weekRange(for pageOffset: Int) -> String {
         let formatter = DateFormatter()
         formatter.dateFormat = "MMM d"
         let weekStart = self.weekStart(for: pageOffset)
         let weekEnd = self.weekEnd(for: pageOffset)
         return "\(formatter.string(from: weekStart)) - \(formatter.string(from: weekEnd))"
     }


    private func monthName(for pageOffset: Int) -> String {
        let weekStart = weekStart(for: pageOffset)
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.string(from: weekStart)
    }

    private func shiftPage(value: Int) {
        currentPage += value
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

extension Calendar {
    func startOfWeek(for date: Date) -> Date {
        let components = dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return self.date(from: components)!
    }
}
