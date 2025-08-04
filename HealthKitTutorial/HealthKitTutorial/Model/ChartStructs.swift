//
//  ChartStructs.swift
//  HealthKitTutorial
//
//  Created by João Vitor Rocha Miranda on 04/08/25.
//

import Foundation
import HealthKit

struct HeartRateSample: Identifiable {
    let id = UUID()
    let timestamp: Date
    let bpm: Double
}

struct WorkoutBPMEntry: Identifiable {
    let id = UUID()
    let date: Date
    let averageBPM: Double
    let workout: HKWorkout
}

struct SleepSegment: Identifiable {
    let id = UUID()
    let startDate: Date
    let endDate: Date
    let value: Int // Category: 0 = In bed, 1 = Asleep
}

struct SleepData: Identifiable {
    let id = UUID()
    let date: Date
    let durationInHours: Double
}

struct SpeedEntry: Identifiable {
    let id = UUID()
    let date: Date
    let speedInKmH: Double
}
