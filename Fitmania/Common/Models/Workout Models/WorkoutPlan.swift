//
//  Workout.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 20/04/2023.
//

import Foundation

struct WorkoutPlan: Codable, Equatable, Hashable {
    let name: String
    let id: WorkoutPlanID
    let parts: [WorkoutPart]
}

struct WorkoutPlanID: Codable, Equatable, Hashable {
    let workoutPlanID: UUID
}

struct FinishedWorkout: Codable, Equatable {
    let workoutPlanName: String
    let workoutID: WorkoutPlanID
    let exercisesDetails: [DetailedExercise]
    let startDate: Date
    let finishDate: Date
}
