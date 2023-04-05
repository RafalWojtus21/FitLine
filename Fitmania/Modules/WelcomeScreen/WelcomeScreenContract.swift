//
//  WelcomeScreenContract.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 05/04/2023.
//

import RxSwift

enum WelcomeScreenIntent {
}

struct WelcomeScreenViewState: Equatable {
}

enum WelcomeScreenEffect: Equatable {
}

struct WelcomeScreenBuilderInput {
}

protocol WelcomeScreenCallback {
}

enum WelcomeScreenResult: Equatable {
    case partialState(_ value: WelcomeScreenPartialState)
    case effect(_ value: WelcomeScreenEffect)
}

enum WelcomeScreenPartialState: Equatable {
    func reduce(previousState: WelcomeScreenViewState) -> WelcomeScreenViewState {
        let state = previousState
        switch self {
        }
        return state
    }
}

protocol WelcomeScreenBuilder {
    func build(with input: WelcomeScreenBuilderInput) -> WelcomeScreenModule
}

struct WelcomeScreenModule {
    let view: WelcomeScreenView
    let callback: WelcomeScreenCallback
}

protocol WelcomeScreenView: BaseView {
    var intents: Observable<WelcomeScreenIntent> { get }
    func render(state: WelcomeScreenViewState)
}

protocol WelcomeScreenPresenter: AnyObject, BasePresenter {
    func bindIntents(view: WelcomeScreenView, triggerEffect: PublishSubject<WelcomeScreenEffect>) -> Observable<WelcomeScreenViewState>
}

protocol WelcomeScreenInteractor: BaseInteractor {
}

protocol WelcomeScreenMiddleware {
    var middlewareObservable: Observable<WelcomeScreenResult> { get }
    func process(result: WelcomeScreenResult) -> Observable<WelcomeScreenResult>
}
