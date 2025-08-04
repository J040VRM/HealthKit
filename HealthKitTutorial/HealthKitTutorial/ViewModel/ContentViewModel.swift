//
//  ContentViewModel.swift
//  Evolv
//
//  Created by João Vitor Rocha Miranda on 16/07/25.
//

import SwiftUI
import HealthKit

/// `ContentViewModel` manages and publishes app-wide activities and user data.
///
/// This view model serves as the central data source for views, handling the interaction
/// between SwiftUI views and the healthKit  `HealthManager`.
///
/// - SeeAlso: `HealthManager`
class ContentViewModel: ObservableObject {
    
    private let healthManager = HealthManager()
    
    //MARK: Workouts
    @Published var workouts: [HKWorkout] = []
    @Published var lastMonthWorkoutCount: Int = 0
    @Published var lastMonthDistance: Double = 0
    @Published var lastMonthWorkoutTime: TimeInterval = 0
    private var lastKnownWorkoutStartDate: Date? = nil
    
    //MARK: Heart
    @Published var generalHeartRateSamples: [HeartRateSample] = []
    @Published var heartRateSamples: [HeartRateSample] = []
    @Published var bpmPerWorkout: [WorkoutBPMEntry] = []
    
    //MARK: Sleep
    @Published var sleepSamples: [HKCategorySample] = []
    @Published var sleepEntries: [SleepData] = []
   
    //MARK: - Functions
    
    /// Request HealthKit permissions and handle result
    func requestHealthPermission(completion: @escaping (Bool) -> Void) {
        healthManager.requestHealthAuthorization { success in
            DispatchQueue.main.async {
                completion(success)
            }
        }
    }
    
    //MARK: Workout Functions
    
    /// Fetch all workouts from the last 3 months
    func fetchAllWorkoutsFromHK() {
        healthManager.fetchAllWorkouts { [weak self] workouts in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                let sortedWorkouts = workouts.sorted(by: { $0.startDate > $1.startDate })
                self.workouts = sortedWorkouts
                
                if let newest = sortedWorkouts.first {
                    if newest.startDate != self.lastKnownWorkoutStartDate {
                        self.lastKnownWorkoutStartDate = newest.startDate
                    }
                }
            }
        }
    }
    
    /// Fetch all workouts from the last month and calculate total distance
    func fetchLastMonthWorkouts() {
        healthManager.fetchLastMonthWorkouts { [weak self] workouts, totalDuration in
            DispatchQueue.main.async {
                self?.lastMonthWorkoutCount = workouts.count
                self?.lastMonthWorkoutTime = totalDuration
            }
        }
    }
    
    //MARK: HeartRates functions
    
    func fetchHeartRates(for workout: HKWorkout) {
        healthManager.fetchHeartRateSamples(for: workout) { samples in
            DispatchQueue.main.async {
                self.generalHeartRateSamples.append(contentsOf: samples)
            }
        }
    }
    
    func fetchActivityHeartRates(for workout: HKWorkout) {
        healthManager.fetchHeartRateSamples(for: workout) { samples in
            DispatchQueue.main.async {
                self.heartRateSamples = samples
            }
        }
    }
    
    func calculateAverageBPMPerWorkout() {
        var result: [WorkoutBPMEntry] = []
        
        for workout in workouts {
            let samplesForWorkout = generalHeartRateSamples.filter {
                $0.timestamp >= workout.startDate && $0.timestamp <= workout.endDate
            }
            
            let bpmValues = samplesForWorkout.map { $0.bpm }
            guard !bpmValues.isEmpty else { continue }
            
            let average = bpmValues.reduce(0, +) / Double(bpmValues.count)
            
            result.append(WorkoutBPMEntry(date: workout.startDate, averageBPM: average, workout: workout))
        }
        
        DispatchQueue.main.async {
            self.bpmPerWorkout = result.sorted(by: { $0.date < $1.date })
        }
    }
    
    func fetchWorkoutsAndHeartRates() {
        fetchAllWorkoutsFromHK()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let group = DispatchGroup()
            
            for workout in self.workouts {
                group.enter()
                self.healthManager.fetchHeartRateSamples(for: workout) { samples in
                    DispatchQueue.main.async {
                        self.generalHeartRateSamples.append(contentsOf: samples)
                        group.leave()
                    }
                }
            }
            
            group.notify(queue: .main) {
                self.calculateAverageBPMPerWorkout()
            }
        }
    }
    
    //MARK: Sleep functions
    
    func calculateSleepPerDay() {
        var dailySleep: [Date: TimeInterval] = [:]
        let calendar = Calendar.current
        
        for sample in sleepSamples {
            let day = calendar.startOfDay(for: sample.startDate)
            let duration = sample.endDate.timeIntervalSince(sample.startDate)
            dailySleep[day, default: 0] += duration
        }
        
        let entries = dailySleep.map { (day, duration) in
            SleepData(date: day, durationInHours: duration / 3600)
        }
        
        self.sleepEntries = entries.sorted(by: { $0.date < $1.date })
    }
    
    func fetchSleepSamples(forLastMonths months: Int = 3) {
        healthManager.fetchRecentSleepSamples { samples in
            DispatchQueue.main.async {
                self.sleepSamples = samples
                self.calculateSleepPerDay()
            }
        }
    }
    
    func fetchSleepData(for workout: HKWorkout) {
        healthManager.fetchSleepSamples(before: workout) { samples in
            DispatchQueue.main.async {
                self.sleepSamples = samples
            }
        }
    }
    
}
