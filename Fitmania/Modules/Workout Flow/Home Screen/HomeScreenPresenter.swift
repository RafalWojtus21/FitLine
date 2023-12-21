//
//  HomeScreenPresenter.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 19/04/2023.
//

import RxSwift

final class HomeScreenPresenterImpl: HomeScreenPresenter {
    typealias View = HomeScreenView
    typealias ViewState = HomeScreenViewState
    typealias Middleware = HomeScreenMiddleware
    typealias Interactor = HomeScreenInteractor
    typealias Effect = HomeScreenEffect
    typealias Result = HomeScreenResult
    
    private let interactor: Interactor
    private let middleware: Middleware
    
    private let initialViewState: ViewState
    
    init(interactor: Interactor, middleware: Middleware, initialViewState: ViewState) {
        self.interactor = interactor
        self.middleware = middleware
        self.initialViewState = initialViewState
    }
    
    func bindIntents(view: View, triggerEffect: PublishSubject<Effect>) -> Observable<ViewState> {
        let intentResults = view.intents.flatMap { [interactor] intent -> Observable<Result> in
            switch intent {
            case .viewLoaded:
                return .merge(interactor.fetchUserInfo(),
                              interactor.subscribeForWorkoutsHistory(),
                              interactor.setPersonalRecords())
            case .startWorkoutButtonIntent:
                return .just(.effect(.showWorkoutsList))
            case .showWorkoutSummaryIntent(workout: let workout):
                return .just(.effect(.showWorkoutSummaryScreen(workout: workout)))
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
