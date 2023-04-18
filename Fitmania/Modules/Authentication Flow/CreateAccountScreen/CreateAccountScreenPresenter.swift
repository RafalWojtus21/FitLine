//
//  CreateAccountScreenPresenter.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 10/04/2023.
//

import RxSwift

final class CreateAccountScreenPresenterImpl: CreateAccountScreenPresenter {
    typealias View = CreateAccountScreenView
    typealias ViewState = CreateAccountScreenViewState
    typealias Middleware = CreateAccountScreenMiddleware
    typealias Interactor = CreateAccountScreenInteractor
    typealias Effect = CreateAccountScreenEffect
    typealias Result = CreateAccountScreenResult
    
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
            case .createAccountButtonIntent(userInfo: let userInfo):
                return interactor.saveUserInfo(userInfo: userInfo)
            case .validateName(text: let text):
                return interactor.validateName(name: text)
            case .validateSex(text: let text):
                return interactor.validateSex(sex: text)
            case .validateAge(text: let text):
                return interactor.validateAge(age: text)
            case .invalidCredentials:
                return .just(.effect(.invalidCredentials))
            case .validateLastName(text: let text):
                return interactor.validateLastName(lastName: text)
            case .validateHeight(text: let text):
                return interactor.validateHeight(height: text)
            case .validateWeight(text: let text):
                return interactor.validateWeight(weight: text)
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
