//
//  ScheduleWorkoutScreenPresenter.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 10/05/2023.
//

import RxSwift

final class ScheduleWorkoutScreenPresenterImpl: ScheduleWorkoutScreenPresenter {
    typealias View = ScheduleWorkoutScreenView
    typealias ViewState = ScheduleWorkoutScreenViewState
    typealias Middleware = ScheduleWorkoutScreenMiddleware
    typealias Interactor = ScheduleWorkoutScreenInteractor
    typealias Effect = ScheduleWorkoutScreenEffect
    typealias Result = ScheduleWorkoutScreenResult
    
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
            case .startNowButtonIntent:
                return .just(.effect(.startNowButtonPressed))
            case .workoutPreviewTapped:
                return .just(.effect(.showWorkoutPreview))
            case .viewLoaded:
                return interactor.calculateWorkoutDetails()
            case .scheduleWorkoutIntent(date: let date):
                return interactor.scheduleWorkoutNotification(for: date)
            case .showDateTimePickerIntent:
                return .just(.effect(.showDateTimePicker(workoutName: initialViewState.chosenWorkout.name)))
            case .editWorkout:
                return .just(.effect(.editWorkout))
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
