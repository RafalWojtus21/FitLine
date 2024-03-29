//
//  WorkoutSetupScreenPresenter.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 25/04/2023.
//

import RxSwift

final class WorkoutSetupScreenPresenterImpl: WorkoutSetupScreenPresenter {
    typealias View = WorkoutSetupScreenView
    typealias ViewState = WorkoutSetupScreenViewState
    typealias Middleware = WorkoutSetupScreenMiddleware
    typealias Interactor = WorkoutSetupScreenInteractor
    typealias Effect = WorkoutSetupScreenEffect
    typealias Result = WorkoutSetupScreenResult
    
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
            case .addExerciseButtonIntent:
                return .just(.effect(.showWorkoutsCategoryListScreen))
            case .viewLoaded:
                return .merge(
                    interactor.setWorkoutData(),
                    interactor.loadExercises()
                )
            case .saveButtonPressed:
                return interactor.saveWorkoutToDatabase()
            case .removeExercise(let exercise):
                return interactor.removeExercise(exercise)
            case .editExercise(let exercise):
                return .just(.effect(.editExercise(workoutPart: exercise)))
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
