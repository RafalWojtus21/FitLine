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
    
    // MARK: - Public Implementation
    
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
    
    func removeExercise(_ exercise: WorkoutPart) -> Observable<WorkoutSetupScreenResult> {
        dependencies.exercisesDataStore.removeExercise(exercise)
        return loadExercises()
    }
    
    func saveWorkoutToDatabase() -> Observable<WorkoutSetupScreenResult> {
        let exercises = dependencies.exercisesDataStore.exercisesRelay.value
        if dependencies.exercisesDataStore.isDataLoaded {
            return saveUpdatedWorkoutPlan(exercises)
        } else {
            return saveNewWorkoutPlan(exercises)
        }
    }
    
    // MARK: - Private Implementation
    
    private func saveNewWorkoutPlan(_ exercises: [WorkoutPart]) -> Observable<WorkoutSetupScreenResult> {
        dependencies.workoutsService.saveNewPersonalTrainingPlan(exercises: exercises)
            .andThen(.just(.effect(.workoutSaved)))
            .catch { _ in
                    .just(.effect(.somethingWentWrong))
            }
    }
    
    private func saveUpdatedWorkoutPlan(_ exercises: [WorkoutPart]) -> Observable<WorkoutSetupScreenResult> {
        guard let workoutPlanID = exercises.first?.workoutPlanID else { return .just(.effect(.somethingWentWrong))}
        return dependencies.workoutsService.deleteWorkoutPlan(id: workoutPlanID)
            .andThen(dependencies.workoutsService.saveNewPersonalTrainingPlan(exercises: exercises))
            .andThen(.just(.effect(.workoutSaved)))
            .catch { _ in
                    .just(.effect(.somethingWentWrong))
            }
    }
}
