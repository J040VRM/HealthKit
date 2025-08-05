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

struct SleepData: Identifiable {
    let id = UUID()
    let date: Date
    let durationInHours: Double
}

