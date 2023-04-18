//
//  RegisterScreenPresenter.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 06/04/2023.
//

import RxSwift

final class RegisterScreenPresenterImpl: RegisterScreenPresenter {
    typealias View = RegisterScreenView
    typealias ViewState = RegisterScreenViewState
    typealias Middleware = RegisterScreenMiddleware
    typealias Interactor = RegisterScreenInteractor
    typealias Effect = RegisterScreenEffect
    typealias Result = RegisterScreenResult
    
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
            case .registerButtonIntent(email: let email, password: let password):
                return interactor.register(email: email, password: password)        
            case .validateRepeatPassword(password: let password, repeatPassword: let repeatPassword):
                return interactor.validateRepeatPassword(password: password, repeatPassword: repeatPassword)
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
