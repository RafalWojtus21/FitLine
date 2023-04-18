//
//  AccountCreatedScreenPresenter.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 18/04/2023.
//

import RxSwift

final class AccountCreatedScreenPresenterImpl: AccountCreatedScreenPresenter {
    typealias View = AccountCreatedScreenView
    typealias ViewState = AccountCreatedScreenViewState
    typealias Middleware = AccountCreatedScreenMiddleware
    typealias Interactor = AccountCreatedScreenInteractor
    typealias Effect = AccountCreatedScreenEffect
    typealias Result = AccountCreatedScreenResult
    
    private let interactor: Interactor
    private let middleware: Middleware
    
    private let initialViewState: ViewState
    
    init(interactor: Interactor, middleware: Middleware, initialViewState: ViewState) {
        self.interactor = interactor
        self.middleware = middleware
        self.initialViewState = initialViewState
    }
    
    func bindIntents(view: View, triggerEffect: PublishSubject<Effect>) -> Observable<ViewState> {
        let intentResults = view.intents.flatMap { intent -> Observable<Result> in
            switch intent {
            case .beginButtonIntent:
                return .just(.effect(.begin))
            }
        }
        return Observable.merge(middleware.middlewareObservable, intentResults)
            .flatMap { self.middleware.process(result: $0) }
            .scan(initialViewState, accumulator: { previousState, result -> ViewState in
                switch result {
                case .partialState(let partialState):
                    return partialState.reduce(previousState: previousState)
                case .effect(let effect):
                    triggerEffect.onNext(effect)
                    return previousState
                }
            })
            .startWith(initialViewState)
            .distinctUntilChanged()
    }
}
