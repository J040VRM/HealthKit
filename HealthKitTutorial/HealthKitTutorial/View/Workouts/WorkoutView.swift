//
//  WorkoutView.swift
//  HealthKitTutorial
//
//  Created by João Vitor Rocha Miranda on 05/08/25.
//

import SwiftUI

struct WorkoutView: View {
    @StateObject var viewModel: ContentViewModel
    
    var body: some View {
        VStack{
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(viewModel.workouts, id: \.uuid) { workout in
                        WorkoutCard(workout: workout)
                            .padding(.vertical)
                    }
                }
                .padding(.top)
            }
        }
        .onAppear{
            viewModel.fetchAllWorkoutsFromHK()
        }
    }
}

