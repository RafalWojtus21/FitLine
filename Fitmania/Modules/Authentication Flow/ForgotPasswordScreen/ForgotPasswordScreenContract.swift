//
//  ForgotPasswordScreenContract.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 09/04/2023.
//

import RxSwift

enum ForgotPasswordScreenIntent {
    case resetPasswordIntent(email: String)
    case validateEmail(text: String)
    case invalidCredentials
    case backToLoginIntent
}

struct ForgotPasswordScreenViewState: Equatable {
    var emailValidationMessage = ValidationMessage(message: "")
    var isResetButtonEnable: Bool { return emailValidationMessage.isValid }
}

enum ForgotPasswordScreenEffect: Equatable {
    case emailSent
    case somethingWentWrong
    case passwordResetError(error: String)
    case invalidCredentials
    case dismiss
}

struct ForgotPasswordScreenBuilderInput {
}

protocol ForgotPasswordScreenCallback {
}

enum ForgotPasswordScreenResult: Equatable {
    case partialState(_ value: ForgotPasswordScreenPartialState)
    case effect(_ value: ForgotPasswordScreenEffect)
}

enum ForgotPasswordScreenPartialState: Equatable {
    case emailValidationResult(validationMessage: ValidationMessage)

    func reduce(previousState: ForgotPasswordScreenViewState) -> ForgotPasswordScreenViewState {
        var state = previousState
        switch self {
        case .emailValidationResult(validationMessage: let validationMessage):
            state.emailValidationMessage = validationMessage
        }
        return state
    }
}

protocol ForgotPasswordScreenBuilder {
    func build(with input: ForgotPasswordScreenBuilderInput) -> ForgotPasswordScreenModule
}

struct ForgotPasswordScreenModule {
    let view: ForgotPasswordScreenView
    let callback: ForgotPasswordScreenCallback
}

protocol ForgotPasswordScreenView: BaseView {
    var intents: Observable<ForgotPasswordScreenIntent> { get }
    func render(state: ForgotPasswordScreenViewState)
}

protocol ForgotPasswordScreenPresenter: AnyObject, BasePresenter {
    func bindIntents(view: ForgotPasswordScreenView, triggerEffect: PublishSubject<ForgotPasswordScreenEffect>) -> Observable<ForgotPasswordScreenViewState>
}

protocol ForgotPasswordScreenInteractor: BaseInteractor {
    func resetPassword(email: String) -> Observable<ForgotPasswordScreenResult>
    func validateEmail(email: String) -> Observable<ForgotPasswordScreenResult>
}

protocol ForgotPasswordScreenMiddleware {
    var middlewareObservable: Observable<ForgotPasswordScreenResult> { get }
    func process(result: ForgotPasswordScreenResult) -> Observable<ForgotPasswordScreenResult>
}
