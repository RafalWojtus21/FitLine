//
//  Workout.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 20/04/2023.
//

import Foundation

struct WorkoutPlan: Codable, Equatable {
    let name: String
    let id: WorkoutPlanID
    let parts: [WorkoutPart]
}

struct WorkoutPart: Codable, Equatable {
    let workoutPlanName: String
    let workoutPlanID: WorkoutPlanID
    let exercise: Exercise
    let time: Int
    let breakTime: Int
}

struct WorkoutPlanID: Codable, Equatable, Hashable {
    let workoutPlanID: UUID
}

struct Exercise: Codable, Equatable {
    let category: Category
    let name: String
}

extension Exercise {
    enum Category: String, CaseIterable, Codable {
        case cardio
        case legs
        case biceps
        case triceps
        case chest
        case shoulders
        case back
    }
}
