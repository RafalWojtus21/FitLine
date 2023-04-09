//
//  ForgotPasswordScreenPresenter.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 09/04/2023.
//

import RxSwift

final class ForgotPasswordScreenPresenterImpl: ForgotPasswordScreenPresenter {
    typealias View = ForgotPasswordScreenView
    typealias ViewState = ForgotPasswordScreenViewState
    typealias Middleware = ForgotPasswordScreenMiddleware
    typealias Interactor = ForgotPasswordScreenInteractor
    typealias Effect = ForgotPasswordScreenEffect
    typealias Result = ForgotPasswordScreenResult
    
    private let interactor: Interactor
    private let middleware: Middleware
    
    private let initialViewState: ViewState
    
    init(interactor: Interactor, middleware: Middleware, initialViewState: ViewState) {
        self.interactor = interactor
        self.middleware = middleware
        self.initialViewState = initialViewState
    }
    
    func bindIntents(view: View, triggerEffect: PublishSubject<Effect>) -> Observable<ViewState> {
        let intentResults = view.intents.flatMap { [unowned self] intent -> Observable<Result> in
            switch intent {
            case .resetPasswordIntent(email: let email):
                return interactor.resetPassword(email: email)
            case .validateEmail(text: let text):
                return interactor.validateEmail(email: text)
            case .invalidCredentials:
                return .just(.effect(.invalidCredentials))
            case .backToLoginIntent:
                return .just(.effect(.dismiss))
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
