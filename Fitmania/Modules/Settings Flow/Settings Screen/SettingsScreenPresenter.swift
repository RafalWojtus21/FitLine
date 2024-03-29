//
//  SettingsScreenPresenter.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 29/05/2023.
//

import RxSwift

final class SettingsScreenPresenterImpl: SettingsScreenPresenter {
    typealias View = SettingsScreenView
    typealias ViewState = SettingsScreenViewState
    typealias Middleware = SettingsScreenMiddleware
    typealias Interactor = SettingsScreenInteractor
    typealias Effect = SettingsScreenEffect
    typealias Result = SettingsScreenResult
    
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
            case .signOutButtonIntent:
                return interactor.signOut()
            case .personalDetailsButtonIntent:
                return .just(.effect(.showPersonalDetailsEdition))
            case .scheduledTrainingsButtonIntent:
                return .just(.effect(.showScheduledTrainings))
            case .showDeleteAccountAlert:
                return .just(.effect(.showDeleteAccountWarning))
            case .deleteAccountButtonIntent:
                return interactor.deleteAccount()
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
