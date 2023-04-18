//
//  RegisterScreenContract.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 06/04/2023.
//

import RxSwift

enum RegisterScreenIntent {
    case registerButtonIntent(email: String, password: String)
    case validateEmail(text: String)
    case validatePassword(text: String)
    case validateRepeatPassword(password: String, repeatPassword: String)
    case invalidCredentials
}

struct RegisterScreenViewState: Equatable {
    var emailValidationMessage = ValidationMessage(message: "")
    var passwordValidationMessage = ValidationMessage(message: "")
    var repeatPasswordValidationMessage = ValidationMessage(message: "")
    var isRegisterButtonEnable: Bool { emailValidationMessage.isValid && passwordValidationMessage.isValid && repeatPasswordValidationMessage.isValid }
}

enum RegisterScreenEffect: Equatable {
    case showAccountSetupScreen
    case registerError(error: String)
    case wrongValidationCase
    case invalidCredentials
}

struct RegisterScreenBuilderInput {
}

protocol RegisterScreenCallback {
}

enum RegisterScreenResult: Equatable {
    case partialState(_ value: RegisterScreenPartialState)
    case effect(_ value: RegisterScreenEffect)
}

enum RegisterScreenPartialState: Equatable {
    case emailValidationResult(validationMessage: ValidationMessage)
    case passwordValidationResult(validationMessage: ValidationMessage)
    case repeatPasswordValidationResult(validationMessage: ValidationMessage)
    
    func reduce(previousState: RegisterScreenViewState) -> RegisterScreenViewState {
        var state = previousState
        switch self {
        case .emailValidationResult(validationMessage: let validationMessage):
            state.emailValidationMessage = validationMessage
        case .passwordValidationResult(validationMessage: let validationMessage):
            state.passwordValidationMessage = validationMessage
        case .repeatPasswordValidationResult(validationMessage: let validationMessage):
            state.repeatPasswordValidationMessage = validationMessage
        }
        return state
    }
}

protocol RegisterScreenBuilder {
    func build(with input: RegisterScreenBuilderInput) -> RegisterScreenModule
}

struct RegisterScreenModule {
    let view: RegisterScreenView
    let callback: RegisterScreenCallback
}

protocol RegisterScreenView: BaseView {
    var intents: Observable<RegisterScreenIntent> { get }
    func render(state: RegisterScreenViewState)
}

protocol RegisterScreenPresenter: AnyObject, BasePresenter {
    func bindIntents(view: RegisterScreenView, triggerEffect: PublishSubject<RegisterScreenEffect>) -> Observable<RegisterScreenViewState>
}

protocol RegisterScreenInteractor: BaseInteractor {
    func register(email: String, password: String) -> Observable<RegisterScreenResult>
    func validateEmail(email: String) -> Observable<RegisterScreenResult>
    func validatePassword(password: String) -> Observable<RegisterScreenResult>
    func validateRepeatPassword(password: String, repeatPassword: String) -> Observable<RegisterScreenResult>
}

protocol RegisterScreenMiddleware {
    var middlewareObservable: Observable<RegisterScreenResult> { get }
    func process(result: RegisterScreenResult) -> Observable<RegisterScreenResult>
}
