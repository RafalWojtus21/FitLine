//
//  WorkoutFinishedScreenPresenter.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 17/05/2023.
//

import RxSwift

final class WorkoutFinishedScreenPresenterImpl: WorkoutFinishedScreenPresenter {
    typealias View = WorkoutFinishedScreenView
    typealias ViewState = WorkoutFinishedScreenViewState
    typealias Middleware = WorkoutFinishedScreenMiddleware
    typealias Interactor = WorkoutFinishedScreenInteractor
    typealias Effect = WorkoutFinishedScreenEffect
    typealias Result = WorkoutFinishedScreenResult
    
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
            case .doneButtonPressed:
                return .just(.effect(.doneButtonEffect))
            case .viewLoaded:
                return interactor.saveWorkoutToHistory()
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
