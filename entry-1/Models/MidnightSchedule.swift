//
//  MidnightSchedule.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 12/7/23.
//

import Foundation
import SwiftUI
import Combine



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



class MyTimer {
    let currentTimePublisher = Timer.publish(every: 1.0, on: .main, in: .default).autoconnect()
    var midnightAction: (() -> Void)?

    init(midnightAction: (() -> Void)? = nil) {
        self.midnightAction = midnightAction

        // Set up a subscriber to check for midnight
        _ = currentTimePublisher.sink { date in
            let calendar = Calendar.current
            let components = calendar.dateComponents([.hour, .minute, .second], from: date)
            if components.hour == 0 && components.minute == 0 && components.second == 0 {
                self.midnightAction?()
            }
        }
    }
}
