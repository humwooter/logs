//
//  LogChartView.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 11/8/23.
//

import Foundation

import SwiftUI
import Charts

struct LogChartView: View {
    @ObservedObject var log: Log

    var body: some View {
//        GroupBox("\(log.day)")  {
            
            Chart {
                ForEach(Array(log.relationship as? Set<Entry> ?? []), id: \.self) { entry in
                    // Assuming `entry.time` is a `Date` and `entry.color` can be converted to a `Color`.
                    PointMark(
                        x: .value("Time", entry.time, unit: .hour),
                        y: .value("Entry", 0) // Y-axis values can be constant since we're only showing one day.
                    )
                    .foregroundStyle(Color(entry.color))
                    .annotation(position: .overlay, alignment:.center) {
                        Image(systemName: entry.image).foregroundColor(Color(entry.color))
                    }
                    .symbolSize(0)
//                                    .annotation(position: .top) {
//                                        Label {
//                                            Text(entry.icon) // If you have a string representation of an icon
//                                        } icon: {
//                                            Image(systemName: entry.icon)
//                                        }
                                    }
                }
            .frame(maxHeight: 50)
//            }
//            .chartXAxis {
//                AxisMarks(preset: .aligned, position: .bottom) { _ in
//                    AxisGridLine()
//                    AxisTick()
//                    AxisValueLabel(format: .dateTime.hour())
//                }
//            }
//        }
        .padding(.horizontal, 20)
        .navigationTitle("Daily Log Entries")
    }
}


struct LogChartView_multipleCharts: View {
    @State var logs: [Log]
    @State var data: [PointMarkData] = []

    var body: some View {
        
        let earliestHour = data.map { Calendar.current.component(.hour, from: $0.time) }.min() ?? 0

        List {
            ScrollView(.vertical) {
                Chart {
                    ForEach(data) { pointData in
                        var hourComponent : Float =  Float(Calendar.current.component(.hour, from: pointData.time))
                        var minuteComponent : Float =  Float(Calendar.current.component(.minute, from: pointData.time))/60.0
                        var totalTime = hourComponent + minuteComponent

                        PointMark(
                            x: .value("Day", pointData.day),
                            y: .value("Time", totalTime)
                        )
                        .annotation(position: .overlay, alignment:.center) {
                            
                            Image(systemName: pointData.image == "" ? "circle.fill" : pointData.image).foregroundColor(pointData.color)
                        }
                        .symbolSize(0)
                    }
                }
                .chartYScale(domain: [-1, 25])
                .frame(minHeight: 0.6 * UIScreen.main.bounds.height)

            }
            
                    

                .padding(.horizontal, 10)
                .navigationTitle("Daily Log Entries")
                .onAppear {
                    self.data = createDataPoints(logs: Array(logs))
                }
        }
    }

    func hourText(_ hour: Int) -> String {

      let formatter = DateFormatter()
      formatter.locale = .current
      formatter.dateFormat = "h a"
      
      return formatter.string(from: DateComponents(hour: hour).date!)
    }
    
    
    private func createDataPoints(logs: [Log]) -> [PointMarkData] {
        var newData: [PointMarkData] = []
        for log in logs {
            if let entries = log.relationship as? Set<Entry> {
                for entry in entries {
                    let point = PointMarkData(
                        day: formattedDateShort(from: entry.time) ?? "", // Assuming `day` is an optional string and providing a default value if nil
                        time: entry.time,
                        color: entry.color != UIColor.tertiarySystemBackground ? Color(entry.color) : Color(UIColor.secondaryLabel), // Ensure entry.color is convertible to Color
                        image: entry.image
                    )
                    print("minute: \(Calendar.current.component(.minute, from: entry.time))")
                    print("hour: \(Calendar.current.component(.hour, from: entry.time))")
                    
                    
                    var hourComponent : Float =  Float(Calendar.current.component(.hour, from: entry.time))
                    var minuteComponent : Float =  Float(Calendar.current.component(.minute, from: entry.time))/60.0
                    var totalTime = hourComponent + minuteComponent
                    
                    print("TOTAL TIME: \(totalTime)")
                    print()

                    newData.append(point)
                }
            }
        }
        return newData
    }
}

struct PointMarkData: Identifiable {
    let id: UUID = UUID()
    let day: String
    let time: Date
    let color: Color
    let image: String
}



