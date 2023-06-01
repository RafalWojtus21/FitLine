//
//  WorkoutSummaryModel.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 02/06/2023.
//

import Foundation

struct WorkoutSummaryModel: Equatable {
    let exerciseName: String
    let exerciseType: Exercise.ExerciseType
    let setsNumber: Int?
    var totalTime: Int?
    var maxWeight: Float?
    var maxRepetitions: Int?
    var distance: Float?
}
