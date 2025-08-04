//
//  Activity.swift
//  HealthKitTutorial
//
//  Created by João Vitor Rocha Miranda on 04/08/25.
//

import Foundation

struct Activity: Identifiable {
    var id: UUID = UUID()
    var title: String
    var subtitle: String
    var image: String
    var amount: String
}
