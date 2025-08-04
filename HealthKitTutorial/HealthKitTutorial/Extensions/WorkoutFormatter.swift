//
//  WorkoutFormatter.swift
//  HealthKitTutorial
//
//  Created by João Vitor Rocha Miranda on 04/08/25.
//

import Foundation
import HealthKit

struct WorkoutFormatter {
    static func dateString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    static func durationString(for seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return "\(minutes) min \(secs) s"
    }

    static func distanceString(for workout: HKWorkout) -> String {
        let km = workout.totalDistance?.doubleValue(for: .meterUnit(with: .kilo)) ?? 0
        return String(format: "%.2f km", km)
    }

    static func caloriesString(for workout: HKWorkout) -> String {
        if let energy = workout.totalEnergyBurned?.doubleValue(for: .kilocalorie()) {
            return String(format: "%.0f kcal", energy)
        }
        return "–"
    }
}

func formattedLastMonthWorkoutTime(lastMonthWorkoutTime: TimeInterval) -> String {
    let hours = Int(lastMonthWorkoutTime) / 3600
    let minutes = (Int(lastMonthWorkoutTime) % 3600) / 60
    let seconds = Int(lastMonthWorkoutTime) % 60
    return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
}
