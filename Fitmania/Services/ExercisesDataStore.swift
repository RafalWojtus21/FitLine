//
//  ExercisesDataStore.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 26/04/2023.
//

import Foundation
import RxSwift
import RxRelay

protocol HasExercisesDataStore {
    var exercisesDataStore: ExercisesDataStore { get }
}

protocol ExercisesDataStore {
    var exercisesRelay: BehaviorRelay<[WorkoutPart]> { get }
    var trainingPlanNameRelay: BehaviorRelay<String> { get }
    var trainingPlanId: String { get }
}

final class ExercisesDataStoreImpl: ExercisesDataStore {
    let exercisesRelay = BehaviorRelay<[WorkoutPart]>(value: [])
    var trainingPlanId = UUID().uuidString
    var trainingPlanNameRelay = BehaviorRelay<String>(value: "")
}
