//
//  ChartsView.swift
//  HealthKitTutorial
//
//  Created by João Vitor Rocha Miranda on 04/08/25.
//

import SwiftUI

struct ChartsView: View {
    @ObservedObject var viewModel: ContentViewModel
    
    var body: some View {
        VStack{
            BPMChartView(viewModel: viewModel)
            SleepHistChart(viewModel: viewModel)
        }
        .onAppear {
            viewModel.fetchWorkoutsAndHeartRates()
            viewModel.fetchSleepSamples(forLastMonths: 3)
        }
    }
    
}

#Preview {
    ChartsView(viewModel: ContentViewModel())
}
