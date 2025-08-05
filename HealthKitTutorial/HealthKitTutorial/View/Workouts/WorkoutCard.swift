//
//  WorkoutCartd.swift
//  HealthKitTutorial
//
//  Created by João Vitor Rocha Miranda on 05/08/25.
//

import SwiftUI
import HealthKit

struct WorkoutCard: View {
    let workout: HKWorkout
    
    var body: some View {
        VStack(alignment: .leading){
            //MARK: Workout Info
            /*Workout Name*/
            Text(" \(workout.activityName)")
                .font(.title3)
                .fontWeight(.semibold)
            
            /*Display workout information*/
            Group {
                Text("∙ Data: \(WorkoutFormatter.dateString(for: workout.startDate))")
                Text("∙ Duração: \(WorkoutFormatter.durationString(for: workout.duration))")
                Text("∙ Distância: \(WorkoutFormatter.distanceString(for: workout))")
                Text("∙ Calorias: \(WorkoutFormatter.caloriesString(for: workout))")
                Text("∙ Origem: \(workout.sourceRevision.source.name)")
            }
            .font(.body)
            .padding()
            
        }
        .background(.blue)
    }
}


