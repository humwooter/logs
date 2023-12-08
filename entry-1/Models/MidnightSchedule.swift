//
//  MidnightSchedule.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 12/7/23.
//

import Foundation
import SwiftUI



struct MidnightSchedule: TimelineSchedule {
    func entries(from startDate: Date, mode: TimelineScheduleMode) -> AnySequence<Date> {
        return generateMidnightDates(startingFrom: startDate)
    }
}

func generateMidnightDates(startingFrom startDate: Date) -> AnySequence<Date> {
    var calendar = Calendar.current
    calendar.timeZone = TimeZone.current

    return AnySequence {
        return AnyIterator {
            guard let nextMidnight = calendar.nextDate(after: startDate, matching: DateComponents(hour: 0, minute: 0, second: 0), matchingPolicy: .nextTime) else {
                return nil
            }

            return nextMidnight
        }
    }
}
