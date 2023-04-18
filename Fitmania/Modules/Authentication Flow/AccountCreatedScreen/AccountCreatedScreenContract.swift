//
//  AccountCreatedScreenContract.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 18/04/2023.
//

import RxSwift

enum AccountCreatedScreenIntent {
    case beginButtonIntent
}

struct AccountCreatedScreenViewState: Equatable {
}

enum AccountCreatedScreenEffect: Equatable {
    case begin
}

struct AccountCreatedScreenBuilderInput {
}

protocol AccountCreatedScreenCallback {
}

enum AccountCreatedScreenResult: Equatable {
    case partialState(_ value: AccountCreatedScreenPartialState)
    case effect(_ value: AccountCreatedScreenEffect)
}

enum AccountCreatedScreenPartialState: Equatable {
    func reduce(previousState: AccountCreatedScreenViewState) -> AccountCreatedScreenViewState {
        let state = previousState
        return state
    }
}

protocol AccountCreatedScreenBuilder {
    func build(with input: AccountCreatedScreenBuilderInput) -> AccountCreatedScreenModule
}

struct AccountCreatedScreenModule {
    let view: AccountCreatedScreenView
    let callback: AccountCreatedScreenCallback
}

protocol AccountCreatedScreenView: BaseView {
    var intents: Observable<AccountCreatedScreenIntent> { get }
    func render(state: AccountCreatedScreenViewState)
}

protocol AccountCreatedScreenPresenter: AnyObject, BasePresenter {
    func bindIntents(view: AccountCreatedScreenView, triggerEffect: PublishSubject<AccountCreatedScreenEffect>) -> Observable<AccountCreatedScreenViewState>
}

protocol AccountCreatedScreenInteractor: BaseInteractor {
}

protocol AccountCreatedScreenMiddleware {
    var middlewareObservable: Observable<AccountCreatedScreenResult> { get }
    func process(result: AccountCreatedScreenResult) -> Observable<AccountCreatedScreenResult>
}
