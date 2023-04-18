//
//  LoginScreenContract.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 07/04/2023.
//

import RxSwift

enum LoginScreenIntent {
    case loginButtonIntent(email: String, password: String)
    case forgotPasswordButtonIntent
    case createAccountButtonIntent
    case validateEmail(text: String)
    case validatePassword(text: String)
    case invalidCredentials
}

struct LoginScreenViewState: Equatable {
    var emailValidationMessage = ValidationMessage(message: "")
    var passwordValidationMessage = ValidationMessage(message: "")
    var isLoginButtonEnable: Bool { emailValidationMessage.isValid && passwordValidationMessage.isValid }
}

enum LoginScreenEffect: Equatable {
    case userLoggedIn
    case wrongCredentialsAlert(error: String)
    case invalidCredentials
    case showForgotPasswordScreen
    case showRegisterScreen
    case wrongValidationCase
}

struct LoginScreenBuilderInput {
}

protocol LoginScreenCallback {
}

enum LoginScreenResult: Equatable {
    case partialState(_ value: LoginScreenPartialState)
    case effect(_ value: LoginScreenEffect)
}

enum LoginScreenPartialState: Equatable {
    case emailValidationResult(validationMessage: ValidationMessage)
    case passwordValidationResult(validationMessage: ValidationMessage)
    
    func reduce(previousState: LoginScreenViewState) -> LoginScreenViewState {
        var state = previousState
        switch self {
        case .emailValidationResult(validationMessage: let validationMessage):
            state.emailValidationMessage = validationMessage
        case .passwordValidationResult(validationMessage: let validationMessage):
            state.passwordValidationMessage = validationMessage
        }
        return state
    }
}

protocol LoginScreenBuilder {
    func build(with input: LoginScreenBuilderInput) -> LoginScreenModule
}

struct LoginScreenModule {
    let view: LoginScreenView
    let callback: LoginScreenCallback
}

protocol LoginScreenView: BaseView {
    var intents: Observable<LoginScreenIntent> { get }
    func render(state: LoginScreenViewState)
}

protocol LoginScreenPresenter: AnyObject, BasePresenter {
    func bindIntents(view: LoginScreenView, triggerEffect: PublishSubject<LoginScreenEffect>) -> Observable<LoginScreenViewState>
}

protocol LoginScreenInteractor: BaseInteractor {
    func login(email: String, password: String) -> Observable<LoginScreenResult>
    func validateEmail(email: String) -> Observable<LoginScreenResult>
    func validatePassword(password: String) -> Observable<LoginScreenResult>
}

protocol LoginScreenMiddleware {
    var middlewareObservable: Observable<LoginScreenResult> { get }
    func process(result: LoginScreenResult) -> Observable<LoginScreenResult>
}
