//
//  AddExerciseScreenPresenter.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 25/04/2023.
//

import RxSwift

final class AddExerciseScreenPresenterImpl: AddExerciseScreenPresenter {
    typealias View = AddExerciseScreenView
    typealias ViewState = AddExerciseScreenViewState
    typealias Middleware = AddExerciseScreenMiddleware
    typealias Interactor = AddExerciseScreenInteractor
    typealias Effect = AddExerciseScreenEffect
    typealias Result = AddExerciseScreenResult
    
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
            case .validateExerciseTime(text: let text):
                return interactor.validateExerciseTime(time: text)
            case .validateExerciseBreakTime(text: let text):
                return interactor.validateExerciseBreakTime(time: text)
            case .addExerciseIntent(time: let time, breakTime: let breakTime):
                return interactor.addExercise(time: time, breakTime: breakTime)
            case .invalidDataSet:
                return .just(.effect(.invalidData))
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
