//
//  LoginScreenPresenter.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 07/04/2023.
//

import RxSwift

final class LoginScreenPresenterImpl: LoginScreenPresenter {
    typealias View = LoginScreenView
    typealias ViewState = LoginScreenViewState
    typealias Middleware = LoginScreenMiddleware
    typealias Interactor = LoginScreenInteractor
    typealias Effect = LoginScreenEffect
    typealias Result = LoginScreenResult
    
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
            case .loginButtonIntent(email: let email, password: let password):
                return interactor.login(email: email, password: password)
            case .forgotPasswordButtonIntent:
                return .just(.effect(.showForgotPasswordScreen))
            case .createAccountButtonIntent:
                return .just(.effect(.showRegisterScreen))
            case .validateEmail(text: let text):
                return interactor.validateEmail(email: text)
            case .validatePassword(text: let text):
                return interactor.validatePassword(password: text)
            case .invalidCredentials:
                return .just(.effect(.invalidCredentials))
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
