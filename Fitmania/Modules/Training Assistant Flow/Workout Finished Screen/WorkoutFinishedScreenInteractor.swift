//
//  WorkoutFinishedScreenInteractor.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 17/05/2023.
//

import RxSwift

final class WorkoutFinishedScreenInteractorImpl: WorkoutFinishedScreenInteractor {
    
    // MARK: Properties

    typealias Dependencies = HasWorkoutsHistoryService
    typealias Result = WorkoutFinishedScreenResult
    
    private let dependencies: Dependencies
    private let input: WorkoutFinishedScreenBuilderInput
    
    // MARK: Initialization

    init(dependencies: Dependencies, input: WorkoutFinishedScreenBuilderInput) {
        self.dependencies = dependencies
        self.input = input
    }
    
    // MARK: Public Implementation

    func saveWorkoutToHistory() -> RxSwift.Observable<WorkoutFinishedScreenResult> {
        return dependencies.workoutsHistoryService.saveFinishedWorkoutToHistory(finishedWorkout: input.workoutDoneModel)
            .andThen(.just(.partialState(.isWorkoutSaved(isSaved: true))))
            .catch { _ in
                    .just(.partialState(.isWorkoutSaved(isSaved: false)))
            }
    }
}
