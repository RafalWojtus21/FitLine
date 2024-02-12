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
    var weightReps: [WeightRepetitionsModel]
    var distance: Float?
    
    struct WeightRepetitionsModel: Equatable {
        let weight: Float?
        let repetitions: Int?
    }
}
