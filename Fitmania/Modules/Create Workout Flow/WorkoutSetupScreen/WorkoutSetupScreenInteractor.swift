//
//  WorkoutSetupScreenInteractor.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 25/04/2023.
//

import RxSwift

final class WorkoutSetupScreenInteractorImpl: WorkoutSetupScreenInteractor {
    typealias Dependencies = HasExercisesDataStore & HasWorkoutsService
    typealias Result = WorkoutSetupScreenResult
    
    private let dependencies: Dependencies
    private let input: WorkoutSetupScreenBuilderInput
    
    init(dependencies: Dependencies, input: WorkoutSetupScreenBuilderInput) {
        self.dependencies = dependencies
        self.input = input
    }
    
    func setWorkoutData() -> Observable<WorkoutSetupScreenResult> {
        dependencies.exercisesDataStore.trainingPlanNameRelay.accept(input.trainingName)
        return .just(.effect(.workoutNameSet))
    }
    
    func loadExercises() -> Observable<WorkoutSetupScreenResult> {
        dependencies.exercisesDataStore.exercisesRelay
            .map { exercises in
                return .partialState(.loadExercises(exercises: exercises))
            }
    }
    
    func saveWorkoutToDatabase() -> Observable<WorkoutSetupScreenResult> {
        return dependencies.workoutsService.saveNewPersonalTrainingPlan(exercises: dependencies.exercisesDataStore.exercisesRelay.value)
            .andThen(.just(.effect(.workoutSaved)))
            .catch { _ in
                    .just(.effect(.somethingWentWrong))
            }
    }
}
