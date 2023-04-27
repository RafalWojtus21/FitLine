//
//  WorkoutsCategoryListScreenPresenter.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 25/04/2023.
//

import RxSwift

final class WorkoutsCategoryListScreenPresenterImpl: WorkoutsCategoryListScreenPresenter {
    typealias View = WorkoutsCategoryListScreenView
    typealias ViewState = WorkoutsCategoryListScreenViewState
    typealias Middleware = WorkoutsCategoryListScreenMiddleware
    typealias Interactor = WorkoutsCategoryListScreenInteractor
    typealias Effect = WorkoutsCategoryListScreenEffect
    typealias Result = WorkoutsCategoryListScreenResult
    
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
            case .cellTapped(category: let category):
                return .just(.effect(.showCategoryExercisesList(category: category)))
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
