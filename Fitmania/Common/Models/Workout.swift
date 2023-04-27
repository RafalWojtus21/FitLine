//
//  Workout.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 20/04/2023.
//

import Foundation

struct WorkoutPlan: Codable, Equatable {
    let name: String
    let id: UUID
    let parts: [WorkoutPart]
}

struct WorkoutPart: Codable, Equatable {
    let workoutPlanName: String
    let workoutPlanID: String
    let exercise: Exercise
    let time: Int
    let breakTime: Int
}

struct Exercise: Codable, Equatable {
    let category: ExerciseCategory
    let name: String
}

extension Exercise {
    enum ExerciseCategory: String, CaseIterable, Codable {
        case cardio
        case legs
        case biceps
        case triceps
        case chest
        case shoulders
        case back
    }
}
