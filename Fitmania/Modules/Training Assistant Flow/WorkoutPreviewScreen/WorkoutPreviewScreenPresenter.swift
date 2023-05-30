//
//  WorkoutPreviewScreenPresenter.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 10/05/2023.
//

import RxSwift

final class WorkoutPreviewScreenPresenterImpl: WorkoutPreviewScreenPresenter {
    typealias View = WorkoutPreviewScreenView
    typealias ViewState = WorkoutPreviewScreenViewState
    typealias Middleware = WorkoutPreviewScreenMiddleware
    typealias Interactor = WorkoutPreviewScreenInteractor
    typealias Effect = WorkoutPreviewScreenEffect
    typealias Result = WorkoutPreviewScreenResult
    
    private let interactor: Interactor
    private let middleware: Middleware
    
    private let initialViewState: ViewState
    
    init(interactor: Interactor, middleware: Middleware, initialViewState: ViewState) {
        self.interactor = interactor
        self.middleware = middleware
        self.initialViewState = initialViewState
    }
    
    func bindIntents(view: View, triggerEffect: PublishSubject<Effect>) -> Observable<ViewState> {
        let intentResults = view.intents.flatMap { _ -> Observable<Result> in
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
