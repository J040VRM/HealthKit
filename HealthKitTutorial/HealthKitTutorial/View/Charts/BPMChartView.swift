//
//  BPMChartView.swift
//  Evolv
//
//  Created by João Vitor Rocha Miranda on 27/07/25.
//

import SwiftUI
import Charts

/// A chart that based on the athletes hear rate evolution on the past 3 months and displays the percentual evolution.
struct BPMChartView: View {
    @ObservedObject var viewModel: ContentViewModel
    @State private var selectedEntry: WorkoutBPMEntry?

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Evolução dos BPM Médios")
                    .font(.headline)
                    .padding(.bottom)
                
                if let change = bpmPercentChange() {
                       Text(String(format: "%+.1f%%", change))
                           .font(.subheadline)
                           .fontWeight(.semibold)
                           .foregroundColor(change >= 0 ? .green : .red)
                           .padding(.bottom)
                   }
            }
            .padding(.horizontal)

            Chart {
                ForEach(viewModel.bpmPerWorkout) { entry in
                    LineMark(
                        x: .value("Data", entry.date),
                        y: .value("BPM Médio", entry.averageBPM)
                    )
                    .interpolationMethod(.catmullRom)

                    PointMark(
                        x: .value("Data", entry.date),
                        y: .value("BPM Médio", entry.averageBPM)
                    )
                    .foregroundStyle(entry.id == selectedEntry?.id ? .antiAccent : .accent)
                }

                if let selected = selectedEntry {
                    RuleMark(x: .value("Data", selected.date))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                        .foregroundStyle(.gray)
                        .annotation(position: .top, alignment: .leading) {
                            Text("\(String(format: "%.0f", selected.averageBPM)) bpm")
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
                AxisMarks(position: .leading)
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
                                        let closest = viewModel.bpmPerWorkout.min(by: {
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
                        .opacity(0.1)
                )
            .frame(height: 250)
            .padding(.horizontal)
        }
    }
    
    /// Function that returns the percentage o heart rate evolution in the past 3 months
    /// - Returns: A double with the evoluttion
    private func bpmPercentChange() -> Double? {
        let entries = viewModel.bpmPerWorkout
        guard entries.count >= 2 else { return nil }

        // Grouped by Month
        let grouped = Dictionary(grouping: entries) { entry in
            Calendar.current.component(.month, from: entry.date)
        }
        
        let sortedMonths = grouped.keys.sorted()
        guard sortedMonths.count >= 2 else { return nil }
        
        let lastMonth = grouped[sortedMonths.last!]!
        let previousMonth = grouped[sortedMonths[sortedMonths.count - 2]]!
        
        let avgLast = lastMonth.map(\.averageBPM).reduce(0,+) / Double(lastMonth.count)
        let avgPrev = previousMonth.map(\.averageBPM).reduce(0,+) / Double(previousMonth.count)
        
        guard avgPrev > 0 else { return nil }
        
        return ((avgLast - avgPrev) / avgPrev) * 100
    }
}

#Preview {
    BPMChartView(viewModel: {
        let vm = ContentViewModel()
        vm.bpmPerWorkout = [
            WorkoutBPMEntry(date: Date(), averageBPM: 150, workout: HKWorkout())
        ]
        return vm
    }())
}
