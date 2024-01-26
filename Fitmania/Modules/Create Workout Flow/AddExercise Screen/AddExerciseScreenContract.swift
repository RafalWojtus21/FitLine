//
//  AddExerciseScreenContract.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 25/04/2023.
//

import RxSwift

enum AddExerciseScreen {
    enum ExerciseType {
        case new
        case updated
    }
}

enum AddExerciseScreenIntent {
    case viewLoaded
    case saveExerciseIntent(sets: String, time: String, breakTime: String, type: AddExerciseScreen.ExerciseType)
    case validateExerciseTime(text: String)
    case validateExerciseBreakTime(text: String)
    case validateSets(text: String)
    case invalidDataSet
}

struct AddExerciseScreenViewState: Equatable {
    var chosenExercise: Exercise
    var exerciseTimeValidationMessage = ValidationMessage(message: "")
    var exerciseBreakTimeValidationMessage = ValidationMessage(message: "")
    var exerciseSetsValidationMessage = ValidationMessage(message: "")

    var isSetsViewVisible: Bool {
        chosenExercise.type == .strength
    }
    var isTimeViewVisible: Bool {
        chosenExercise.type == .cardio
    }
    
    enum ValidationDictionaryKeys: String {
        case setsField
        case timeField
        case breakTimeField
    }
    
    var validationDictionary: [ValidationDictionaryKeys: Bool] {
        var dictionary: [ValidationDictionaryKeys: Bool] = [
                  .breakTimeField: exerciseBreakTimeValidationMessage.isValid
        ]
        if isSetsViewVisible {
            dictionary[.setsField] = exerciseSetsValidationMessage.isValid
        }
        if isTimeViewVisible {
            dictionary[.timeField] = exerciseTimeValidationMessage.isValid
        }
        return dictionary
    }
    
    var isAddButtonEnabled: Bool {
        validationDictionary.values.allSatisfy { $0 == true }
    }
    
    var workoutPart: WorkoutPart?
    var shouldLoadExerciseData = false
    
    var isSaveButtonVisible: Bool {
        workoutPart != nil
    }
}

enum AddExerciseScreenEffect: Equatable {
    case exerciseAdded
    case somethingWentWrong
    case invalidData
}

struct AddExerciseScreenBuilderInput {
    let chosenExercise: Exercise
    let exerciseToEdit: WorkoutPart?
}

protocol AddExerciseScreenCallback {
}

enum AddExerciseScreenResult: Equatable {
    case partialState(_ value: AddExerciseScreenPartialState)
    case effect(_ value: AddExerciseScreenEffect)
}

enum AddExerciseScreenPartialState: Equatable {
    case exerciseTimeValidationResult(validationMessage: ValidationMessage)
    case exerciseBreakTimeValidationResult(validationMessage: ValidationMessage)
    case exerciseSetsValidationResult(validationMessage: ValidationMessage)
    case loadWorkoutPart(workoutPart: WorkoutPart)
    case idle

    func reduce(previousState: AddExerciseScreenViewState) -> AddExerciseScreenViewState {
        var state = previousState
        state.shouldLoadExerciseData = false
        switch self {
        case .exerciseTimeValidationResult(validationMessage: let validationMessage):
            state.exerciseTimeValidationMessage = validationMessage
        case .exerciseBreakTimeValidationResult(validationMessage: let validationMessage):
            state.exerciseBreakTimeValidationMessage = validationMessage
        case .exerciseSetsValidationResult(validationMessage: let validationMessage):
            state.exerciseSetsValidationMessage = validationMessage
        case .loadWorkoutPart(workoutPart: let workoutPart):
            state.workoutPart = workoutPart
            state.shouldLoadExerciseData = true
        case .idle:
            break
        }
        return state
    }
}

protocol AddExerciseScreenBuilder {
    func build(with input: AddExerciseScreenBuilderInput) -> AddExerciseScreenModule
}

struct AddExerciseScreenModule {
    let view: AddExerciseScreenView
    let callback: AddExerciseScreenCallback
}

protocol AddExerciseScreenView: BaseView {
    var intents: Observable<AddExerciseScreenIntent> { get }
    func render(state: AddExerciseScreenViewState)
}

protocol AddExerciseScreenPresenter: AnyObject, BasePresenter {
    func bindIntents(view: AddExerciseScreenView, triggerEffect: PublishSubject<AddExerciseScreenEffect>) -> Observable<AddExerciseScreenViewState>
}

protocol AddExerciseScreenInteractor: BaseInteractor {
    func loadExercise() -> Observable<AddExerciseScreenResult>
    func validateExerciseTime(time: String) -> Observable<AddExerciseScreenResult>
    func validateExerciseBreakTime(time: String) -> Observable<AddExerciseScreenResult>
    func validateSets(sets: String) -> Observable<AddExerciseScreenResult>
    func saveExercise(sets: String, time: String, breakTime: String, type: AddExerciseScreen.ExerciseType) -> Observable<AddExerciseScreenResult>
}

protocol AddExerciseScreenMiddleware {
    var middlewareObservable: Observable<AddExerciseScreenResult> { get }
    func process(result: AddExerciseScreenResult) -> Observable<AddExerciseScreenResult>
}
