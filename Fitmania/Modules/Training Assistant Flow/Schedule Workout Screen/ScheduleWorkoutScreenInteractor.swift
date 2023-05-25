//
//  ScheduleWorkoutScreenInteractor.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 10/05/2023.
//

import RxSwift
import Foundation

final class ScheduleWorkoutScreenInteractorImpl: ScheduleWorkoutScreenInteractor {
    typealias Dependencies = Any
    typealias Result = ScheduleWorkoutScreenResult
    
    private let dependencies: Dependencies
    private let chosenWorkout: WorkoutPlan
    
    init(dependencies: Dependencies, chosenWorkout: WorkoutPlan) {
        self.dependencies = dependencies
        self.chosenWorkout = chosenWorkout
    }
    
    func calculateWorkoutDetails() -> RxSwift.Observable<ScheduleWorkoutScreenResult> {
        let totalWorkoutTimeInSeconds: Int = chosenWorkout.parts.reduce(0) { $0 + ($1.details.time ?? 0) + $1.details.breakTime }
        let totalWorkoutTimeInMinutes = Int(ceil(Double(totalWorkoutTimeInSeconds) / 60.0))
        let categories = Array(Set(chosenWorkout.parts.map { $0.exercise.category }))
        return .just(.partialState(.updateWorkoutInfo(totalWorkoutTimeInSeconds: totalWorkoutTimeInSeconds, totalWorkoutTimeInMinutes: totalWorkoutTimeInMinutes, categories: categories)))
    }
}
