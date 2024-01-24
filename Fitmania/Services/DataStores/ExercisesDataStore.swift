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
    var trainingPlanId: UUID { get }
    var isDataLoaded: Bool { get }
    func loadWorkoutPlan(_ workoutPlan: WorkoutPlan)
    func removeExercise(_ workoutPart: WorkoutPart)
}

final class ExercisesDataStoreImpl: ExercisesDataStore {
    let exercisesRelay = BehaviorRelay<[WorkoutPart]>(value: [])
    var trainingPlanId = UUID()
    var trainingPlanNameRelay = BehaviorRelay<String>(value: "")
    private(set) var isDataLoaded = false
    
    func loadWorkoutPlan(_ workoutPlan: WorkoutPlan) {
        exercisesRelay.accept(workoutPlan.parts)
        trainingPlanId = workoutPlan.id.workoutPlanID
        isDataLoaded = true
    }
    
    func removeExercise(_ workoutPart: WorkoutPart) {
        var updatedExercises = exercisesRelay.value
        if let index = updatedExercises.firstIndex(of: workoutPart) {
            updatedExercises.remove(at: index)
            exercisesRelay.accept(updatedExercises)
        }
    }
}
