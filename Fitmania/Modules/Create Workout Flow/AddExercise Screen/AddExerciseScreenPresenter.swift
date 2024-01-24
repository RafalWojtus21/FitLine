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
    private let loadedExercise: WorkoutPart?
    
    init(interactor: Interactor, middleware: Middleware, initialViewState: ViewState, loadedExercise: WorkoutPart?) {
        self.interactor = interactor
        self.middleware = middleware
        self.initialViewState = initialViewState
        self.loadedExercise = loadedExercise
    }
    
    func bindIntents(view: View, triggerEffect: PublishSubject<Effect>) -> Observable<ViewState> {
        let intentResults = view.intents.flatMap { [unowned self] intent -> Observable<Result> in
            switch intent {
            case .validateExerciseTime(text: let text):
                return interactor.validateExerciseTime(time: text)
            case .validateExerciseBreakTime(text: let text):
                return interactor.validateExerciseBreakTime(time: text)
            case .invalidDataSet:
                return .just(.effect(.invalidData))
            case .validateSets(text: let text):
                return interactor.validateSets(sets: text)
            case .viewLoaded:
                return loadedExercise != nil ? interactor.loadExercise() : .just(.effect(.invalidData))
            case .saveExerciseIntent(sets: let sets, time: let time, breakTime: let breakTime, type: let type):
                return interactor.saveExercise(sets: sets, time: time, breakTime: breakTime, type: type)
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
