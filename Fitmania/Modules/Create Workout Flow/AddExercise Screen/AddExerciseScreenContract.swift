//
//  AddExerciseScreenContract.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 25/04/2023.
//

import RxSwift

enum AddExerciseScreenIntent {
    case addExerciseIntent(sets: String, time: String, breakTime: String)
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
}

enum AddExerciseScreenEffect: Equatable {
    case exerciseAdded
    case somethingWentWrong
    case invalidData
}

struct AddExerciseScreenBuilderInput {
    let chosenExercise: Exercise
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

    func reduce(previousState: AddExerciseScreenViewState) -> AddExerciseScreenViewState {
        var state = previousState
        switch self {
        case .exerciseTimeValidationResult(validationMessage: let validationMessage):
            state.exerciseTimeValidationMessage = validationMessage
        case .exerciseBreakTimeValidationResult(validationMessage: let validationMessage):
            state.exerciseBreakTimeValidationMessage = validationMessage
        case .exerciseSetsValidationResult(validationMessage: let validationMessage):
            state.exerciseSetsValidationMessage = validationMessage
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
    func validateExerciseTime(time: String) -> Observable<AddExerciseScreenResult>
    func validateExerciseBreakTime(time: String) -> Observable<AddExerciseScreenResult>
    func validateSets(sets: String) -> Observable<AddExerciseScreenResult>
    func addExercise(sets: String, time: String, breakTime: String) -> Observable<AddExerciseScreenResult>
}

protocol AddExerciseScreenMiddleware {
    var middlewareObservable: Observable<AddExerciseScreenResult> { get }
    func process(result: AddExerciseScreenResult) -> Observable<AddExerciseScreenResult>
}
