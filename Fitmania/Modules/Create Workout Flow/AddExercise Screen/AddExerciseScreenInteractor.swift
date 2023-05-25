//
//  AddExerciseScreenInteractor.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 25/04/2023.
//

import RxSwift

final class AddExerciseScreenInteractorImpl: AddExerciseScreenInteractor {
    
    typealias Dependencies = HasWorkoutsService & HasExercisesDataStore & HasValidationService
    typealias Result = AddExerciseScreenResult
    
    private let dependencies: Dependencies
    private let input: AddExerciseScreenBuilderInput
    private var chosenExerciseType: Exercise.ExerciseType { input.chosenExercise.type }
    
    init(dependencies: Dependencies, input: AddExerciseScreenBuilderInput) {
        self.dependencies = dependencies
        self.input = input
    }
    
    func addExercise(sets: String, time: String, breakTime: String) -> RxSwift.Observable<AddExerciseScreenResult> {
        let planName = dependencies.exercisesDataStore.trainingPlanNameRelay.value
        let planID = dependencies.exercisesDataStore.trainingPlanId
        // swiftlint:disable force_unwrapping
        let setsNumber: Int?
        let timeValue: Int?
        if !sets.isEmpty && time.isEmpty {
            setsNumber = Int(sets)
            timeValue = nil
        } else if !time.isEmpty && sets.isEmpty {
            setsNumber = nil
            timeValue = Int(time)
        } else {
            setsNumber = nil
            timeValue = nil
        }
        let workoutPart = WorkoutPart(workoutPlanName: planName, workoutPlanID: WorkoutPlanID(workoutPlanID: planID), exercise: Exercise(category: input.chosenExercise.category, name: input.chosenExercise.name), details: WorkoutPart.Details(sets: setsNumber, time: timeValue, breakTime: Int(breakTime)!))
        // swiftlint:enable force_unwrapping
        var workouts = dependencies.exercisesDataStore.exercisesRelay.value
        workouts.append(workoutPart)
        dependencies.exercisesDataStore.exercisesRelay.accept(workouts)
        return .just(.effect(.exerciseAdded))
    }
    
    func validateSets(sets: String) -> RxSwift.Observable<AddExerciseScreenResult> {
        dependencies.validationService.validate(.workoutSets, input: sets)
            .andThen(.just(.partialState(.exerciseSetsValidationResult(validationMessage: ValidationMessage(message: nil)))))
            .catch { error -> Observable<AddExerciseScreenResult> in
                return .just(.partialState(.exerciseSetsValidationResult(validationMessage: ValidationMessage(message: error.localizedDescription))))
            }
    }
    
    func validateExerciseTime(time: String) -> RxSwift.Observable<AddExerciseScreenResult> {
        return dependencies.validationService.validate(.workoutTime, input: time)
            .andThen(.just(.partialState(.exerciseTimeValidationResult(validationMessage: ValidationMessage(message: nil)))))
            .catch { error -> Observable<AddExerciseScreenResult> in
                return .just(.partialState(.exerciseTimeValidationResult(validationMessage: ValidationMessage(message: error.localizedDescription))))
            }
    }
    
    func validateExerciseBreakTime(time: String) -> RxSwift.Observable<AddExerciseScreenResult> {
        return dependencies.validationService.validate(.workoutTime, input: time)
            .andThen(.just(.partialState(.exerciseBreakTimeValidationResult(validationMessage: ValidationMessage(message: nil)))))
            .catch { error -> Observable<AddExerciseScreenResult> in
                return .just(.partialState(.exerciseBreakTimeValidationResult(validationMessage: ValidationMessage(message: error.localizedDescription))))
            }
    }
}
