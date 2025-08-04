//
//  HealthKitControler.swift
//  HealthKitTutorial
//
//  Created by João Vitor Rocha Miranda on 04/08/25.
//

import Foundation
import HealthKit

class HealthManager: ObservableObject {
    
    /// HealthKit store used to request data
    let healthStore = HKHealthStore()
    
    /// Array that stores all workouts fetched
    @Published var workouts: [HKWorkout] = []
    
    /// Custom app-specific activities (if needed in future)
    @Published var activities: [Activity] = []

    /// Requests authorization to read health data from HealthKit
    /// - Parameter completion: Completion handler with success flag
    func requestHealthAuthorization(completion: @escaping (Bool) -> Void) {
        let quantityTypes: [HKQuantityType] = [
            .quantityType(forIdentifier: .stepCount)!,
            .quantityType(forIdentifier: .distanceWalkingRunning)!,
            .quantityType(forIdentifier: .activeEnergyBurned)!,
            .quantityType(forIdentifier: .heartRate)!
        ]

        let categoryTypes: [HKCategoryType] = [
            .categoryType(forIdentifier: .sleepAnalysis)!,
            .categoryType(forIdentifier: .mindfulSession)!
        ]

        let typesToRead: Set<HKObjectType> = Set(
            quantityTypes.map { $0 as HKObjectType } +
            categoryTypes.map { $0 as HKObjectType } +
            [HKObjectType.workoutType()]
        )

        Task {
            do {
                try await healthStore.requestAuthorization(toShare: [], read: typesToRead)
                completion(true)
            } catch {
                print("Authorization failed: \(error)")
                completion(false)
            }
        }
    }
    
    /// Fetches all workouts
    func fetchAllWorkouts(completion: @escaping ([HKWorkout]) -> Void) {
        let workoutType = HKSampleType.workoutType()
        let startDate = Calendar.current.date(byAdding: .month, value: -3, to: Date()) ?? .distantPast
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date())

        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

        let query = HKSampleQuery(
            sampleType: workoutType,
            predicate: predicate,
            limit: 100,
            sortDescriptors: [sortDescriptor]
        ) { _, samples, error in
            guard let workouts = samples as? [HKWorkout], error == nil else {
                print("Error feetching workouts: \(String(describing: error))")
                completion([])
                return
            }
            completion(workouts)
        }

        healthStore.execute(query)
    }
    
    /// Fetches last month workouts
    func fetchLastMonthWorkouts(completion: @escaping ([HKWorkout], TimeInterval) -> Void) {
    let workoutType = HKSampleType.workoutType()
    let calendar = Calendar.current
    let now = Date()
    
    guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) else {
        completion([], 0)
        return
    }
    
    let predicate = HKQuery.predicateForSamples(withStart: startOfMonth, end: now)
    let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

    let query = HKSampleQuery(
        sampleType: workoutType,
        predicate: predicate,
        limit: 100,
        sortDescriptors: [sortDescriptor]
    ) { _, samples, error in
        guard let workouts = samples as? [HKWorkout], error == nil else {
            print("Error fetching workouts from this month: \(String(describing: error))")
            completion([], 0)
            return
        }

        // Calculates total activity time
        let totalDuration = workouts.reduce(0) { $0 + $1.duration }

        completion(workouts, totalDuration)
    }

    healthStore.execute(query)
}

    
    /// Fetch workouts by specific type (e.g., .running, .cycling)
    /// - Parameter type: `HKWorkoutActivityType` to filter
    func fetchWorkouts(ofType type: HKWorkoutActivityType) {
        let predicate = HKQuery.predicateForWorkouts(with: type)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: .workoutType(),
                                  predicate: predicate,
                                  limit: 100,
                                  sortDescriptors: [sortDescriptor]) { _, samples, error in
            guard let workouts = samples as? [HKWorkout], error == nil else {
                print("Error fetching workouts of type \(type): \(String(describing: error))")
                return
            }

            DispatchQueue.main.async {
                self.workouts = workouts
            }
        }

        healthStore.execute(query)
    }
    
    /// Fetch HeartRateSample for a specific workout
    func fetchHeartRateSamples(for workout: HKWorkout, completion: @escaping ([HeartRateSample]) -> Void) {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let predicate = HKQuery.predicateForSamples(withStart: workout.startDate, end: workout.endDate)
        
        let query = HKSampleQuery(sampleType: heartRateType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, error in
            guard let quantitySamples = samples as? [HKQuantitySample], error == nil else {
                completion([])
                return
            }

            let heartRates = quantitySamples.map {
                HeartRateSample(
                    timestamp: $0.startDate,
                    bpm: $0.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
                )
            }
            completion(heartRates)
        }
        
        healthStore.execute(query)
    }
    
    /// Fetch HeartRateSample before a specific time
    func fetchSleepSamples(before workout: HKWorkout, completion: @escaping ([HKCategorySample]) -> Void) {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            completion([])
            return
        }

        let endDate = workout.startDate
        let startDate = Calendar.current.date(byAdding: .hour, value: -18, to: endDate) ?? .distantPast

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictEndDate)

        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, error in
            guard let sleepSamples = samples as? [HKCategorySample], error == nil else {
                print("Error fetching sleep data: \(error?.localizedDescription ?? "Error")")
                completion([])
                return
            }

            completion(sleepSamples)
        }

        healthStore.execute(query)
    }
    
    /// Fetch sleep samples
    func fetchRecentSleepSamples(completion: @escaping ([HKCategorySample]) -> Void) {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            completion([])
            return
        }

        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .month, value: -3, to: endDate) ?? .distantPast

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictEndDate)

        let query = HKSampleQuery(
            sampleType: sleepType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]
        ) { _, samples, error in
            guard let sleepSamples = samples as? [HKCategorySample], error == nil else {
                print("Erro ao buscar sono: \(error?.localizedDescription ?? "desconhecido")")
                completion([])
                return
            }

            completion(sleepSamples)
        }

        healthStore.execute(query)
    }
    
}
