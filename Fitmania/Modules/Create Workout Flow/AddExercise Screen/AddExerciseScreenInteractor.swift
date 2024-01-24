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
    private var loadedExercise: WorkoutPart?
    
    init(dependencies: Dependencies, input: AddExerciseScreenBuilderInput, loadedExercise: WorkoutPart?) {
        self.dependencies = dependencies
        self.input = input
        self.loadedExercise = loadedExercise
    }
    
    func loadExercise() -> Observable<AddExerciseScreenResult> {
        guard let loadedExercise else { return .just(.partialState(.idle)) }
        return .just(.partialState(.loadWorkoutPart(workoutPart: loadedExercise)))
    }
    
    func saveExercise(sets: String, time: String, breakTime: String, type: AddExerciseScreen.ExerciseType) -> Observable<AddExerciseScreenResult> {
        switch type {
        case .new:
            processExercise(sets: sets, time: time, breakTime: breakTime, type: .new)
        case .updated:
            processExercise(sets: sets, time: time, breakTime: breakTime, type: .updated)
        }
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
    
    private func processExercise(sets: String, time: String, breakTime: String, type: AddExerciseScreen.ExerciseType) -> Observable<AddExerciseScreenResult> {
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
        
        var workouts = dependencies.exercisesDataStore.exercisesRelay.value
        var workoutPart = WorkoutPart(workoutPlanName: planName, workoutPlanID: WorkoutPlanID(workoutPlanID: planID), exercise: Exercise(category: input.chosenExercise.category, name: input.chosenExercise.name), details: WorkoutPart.Details(sets: setsNumber, time: timeValue, breakTime: Int(breakTime)!), id: loadedExercise?.id ?? .init())
        switch type {
        case .new:
            workouts.append(workoutPart)
        case .updated:
            if let index = workouts.firstIndex(where: { $0.id == workoutPart.id }) {
                workouts[index] = workoutPart
            }
        }
        dependencies.exercisesDataStore.exercisesRelay.accept(workouts)
        return .just(.effect(.exerciseAdded))
    }
}
