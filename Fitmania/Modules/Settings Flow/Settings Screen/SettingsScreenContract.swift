//
//  SettingsScreenContract.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 29/05/2023.
//

import RxSwift

enum SettingsScreenIntent {
    case signOutButtonIntent
}

struct SettingsScreenViewState: Equatable {
}

enum SettingsScreenEffect: Equatable {
    case showWelcomeScreen
    case somethingWentWrong
    case signOutErrorAlert(error: String)
}

struct SettingsScreenBuilderInput {
}

protocol SettingsScreenCallback {
}

enum SettingsScreenResult: Equatable {
    case partialState(_ value: SettingsScreenPartialState)
    case effect(_ value: SettingsScreenEffect)
}

enum SettingsScreenPartialState: Equatable {
    func reduce(previousState: SettingsScreenViewState) -> SettingsScreenViewState {
        let state = previousState
        return state
    }
}

protocol SettingsScreenBuilder {
    func build(with input: SettingsScreenBuilderInput) -> SettingsScreenModule
}

struct SettingsScreenModule {
    let view: SettingsScreenView
    let callback: SettingsScreenCallback
}

protocol SettingsScreenView: BaseView {
    var intents: Observable<SettingsScreenIntent> { get }
    func render(state: SettingsScreenViewState)
}

protocol SettingsScreenPresenter: AnyObject, BasePresenter {
    func bindIntents(view: SettingsScreenView, triggerEffect: PublishSubject<SettingsScreenEffect>) -> Observable<SettingsScreenViewState>
}

protocol SettingsScreenInteractor: BaseInteractor {
    func signOut() -> Observable<SettingsScreenResult>
}

protocol SettingsScreenMiddleware {
    var middlewareObservable: Observable<SettingsScreenResult> { get }
    func process(result: SettingsScreenResult) -> Observable<SettingsScreenResult>
}
