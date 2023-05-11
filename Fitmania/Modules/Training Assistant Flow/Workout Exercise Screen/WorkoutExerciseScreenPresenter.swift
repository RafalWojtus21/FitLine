//
//  WorkoutExerciseScreenPresenter.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 11/05/2023.
//

import RxSwift

final class WorkoutExerciseScreenPresenterImpl: WorkoutExerciseScreenPresenter {
    typealias View = WorkoutExerciseScreenView
    typealias ViewState = WorkoutExerciseScreenViewState
    typealias Middleware = WorkoutExerciseScreenMiddleware
    typealias Interactor = WorkoutExerciseScreenInteractor
    typealias Effect = WorkoutExerciseScreenEffect
    typealias Result = WorkoutExerciseScreenResult
    
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
            case .startEventIntent:
                return interactor.triggerFirstExercise()
            case .pauseButtonIntent:
                return interactor.pauseTimer()
            case .resumeButtonIntent:
                return interactor.resumeTimer()
            case .nextEventButtonIntent:
                return interactor.triggerNextExercise()
            case .viewLoaded:
                return .merge(interactor.loadEvents(), interactor.observeForExercises())
            case .plusButtonIntent:
                return interactor.getCurrentExercise()
            case .saveButtonPressed(details: let details):
                return interactor.saveDetailOfCurrentExercise(details: details)
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
