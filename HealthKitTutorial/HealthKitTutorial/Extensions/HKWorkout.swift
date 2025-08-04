//
//  HKWorkout.swift
//  HealthKitTutorial
//
//  Created by João Vitor Rocha Miranda on 04/08/25.
//

import Foundation
import HealthKit

extension HKWorkout {
    var activityName: String {
        let type = self.workoutActivityType
        let source = self.sourceRevision.source.name

        if source.lowercased().contains("strava") && ![
            .running,
            .cycling,
            .walking,
            .swimming,
            .traditionalStrengthTraining
        ].contains(type) {
            return "Musculação"
        }

        switch type {
        case .running: return "Corrida"
        case .cycling: return "Ciclismo"
        case .walking: return "Caminhada"
        case .swimming: return "Natação"
        case .traditionalStrengthTraining: return "Musculação"
        default: return "Outro (\(type.rawValue))"
        }
    }
}
