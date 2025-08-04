//
//  SleepHistChart.swift
//  Evolv
//
//  Created by João Vitor Rocha Miranda on 27/07/25.
//

import SwiftUI
import Charts

struct SleepHistChart: View {
    @ObservedObject var viewModel: ContentViewModel
    @State private var selectedEntry: SleepData?

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Tempo Dormido por Mês")
                    .font(.headline)
                    .padding(.bottom)
                
                if let change = sleepPercentChange() {
                        Text(String(format: "%+.1f%%", change))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(change >= 0 ? .green : .red)
                            .padding(.bottom)
                    }
            }
            .padding(.horizontal)

            Chart {
                ForEach(viewModel.sleepEntries) { entry in
                    LineMark(
                        x: .value("Mês", entry.date),
                        y: .value("Horas Dormidas", entry.durationInHours)
                    )
                    .interpolationMethod(.catmullRom)

                    PointMark(
                        x: .value("Mês", entry.date),
                        y: .value("Horas Dormidas", entry.durationInHours)
                    )
                    .foregroundStyle(entry.id == selectedEntry?.id ? .antiAccent : .accent)
                }

                if let selected = selectedEntry {
                    RuleMark(x: .value("Mês", selected.date))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [4]))
                        .foregroundStyle(.gray)
                        .annotation(position: .top) {
                            Text("\(String(format: "%.1f", selected.durationInHours)) h")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .month)) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(format: .dateTime.month(.abbreviated))
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) {
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel()
                }
            }
            .chartOverlay { proxy in
                GeometryReader { geometry in
                    Rectangle()
                        .fill(Color.clear)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let location = value.location
                                    if let date: Date = proxy.value(atX: location.x) {
                                        let closest = viewModel.sleepEntries.min(by: {
                                            abs($0.date.timeIntervalSince(date)) <
                                            abs($1.date.timeIntervalSince(date))
                                        })
                                        selectedEntry = closest
                                    }
                                }
                        )
                }
            }
            .padding()
            .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.black, lineWidth: 2)
                        .fill(.gray)
                        .opacity(0.1)
                )
            .frame(height: 250)
            .padding(.horizontal)
        }
    }
    
    /// Function that returns the percentage o sleep evolution in the past 3 months
    /// - Returns: A double with the evoluttion
    private func sleepPercentChange() -> Double? {
        let entries = viewModel.sleepEntries
        guard entries.count >= 2 else { return nil }

        
        let grouped = Dictionary(grouping: entries) { entry in
            Calendar.current.component(.month, from: entry.date)
        }
        
       
        let sortedMonths = grouped.keys.sorted()
        guard sortedMonths.count >= 2 else { return nil }

        let lastMonth = grouped[sortedMonths.last!]!
        let previousMonth = grouped[sortedMonths[sortedMonths.count - 2]]!

        let avgLast = lastMonth.map(\.durationInHours).reduce(0,+) / Double(lastMonth.count)
        let avgPrev = previousMonth.map(\.durationInHours).reduce(0,+) / Double(previousMonth.count)

        guard avgPrev > 0 else { return nil }

        return ((avgLast - avgPrev) / avgPrev) * 100
    }
}
