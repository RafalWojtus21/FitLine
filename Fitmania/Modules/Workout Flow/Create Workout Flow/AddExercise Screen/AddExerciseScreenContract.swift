//
//  AddExerciseScreenContract.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 25/04/2023.
//

import RxSwift

enum AddExerciseScreenIntent {
    case addExerciseIntent(time: String, breakTime: String)
    case validateExerciseTime(text: String)
    case validateExerciseBreakTime(text: String)
    case invalidDataSet
}

struct AddExerciseScreenViewState: Equatable {
    var chosenExercise: Exercise
    var exerciseTimeValidationMessage = ValidationMessage(message: "")
    var exerciseBreakTimeValidationMessage = ValidationMessage(message: "")
    var isAddButtonEnabled: Bool { exerciseTimeValidationMessage.isValid && exerciseBreakTimeValidationMessage.isValid }
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
    func reduce(previousState: AddExerciseScreenViewState) -> AddExerciseScreenViewState {
        var state = previousState
        switch self {
        case .exerciseTimeValidationResult(validationMessage: let validationMessage):
            state.exerciseTimeValidationMessage = validationMessage
        case .exerciseBreakTimeValidationResult(validationMessage: let validationMessage):
            state.exerciseBreakTimeValidationMessage = validationMessage
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
    func addExercise(time: String, breakTime: String) -> Observable<AddExerciseScreenResult>
}

protocol AddExerciseScreenMiddleware {
    var middlewareObservable: Observable<AddExerciseScreenResult> { get }
    func process(result: AddExerciseScreenResult) -> Observable<AddExerciseScreenResult>
}
