//
//  ContentView.swift
//  HealthKitTutorial
//
//  Created by João Vitor Rocha Miranda on 04/08/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = ContentViewModel()
    @State var didAllowHealth = false
    
    var body: some View {
        TabView{
            UserInfoView()
                .tabItem{
                    Label("user", systemImage: "person")
                }
                .onAppear{
                   viewModel.requestHealthPermission { success in
                        if success { didAllowHealth = true }
                    }
                }
            ChartsView(viewModel: viewModel)
                .tabItem{
                    Label("charts", systemImage: "chart.line.text.clipboard")
                }
        }
    }
}

#Preview {
    ContentView()
}
