//
//  HomeScreenContract.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 19/04/2023.
//

import RxSwift

enum HomeScreenIntent {
    case plusButtonIntent
    case viewLoaded
    case showWorkoutSummaryIntent(workout: FinishedWorkout)
}

struct HomeScreenViewState: Equatable {
    var workoutsHistory: [FinishedWorkout] = []
}

enum HomeScreenEffect: Equatable {
    case showWorkoutsList
    case showWorkoutSummaryScreen(workout: FinishedWorkout)
}

struct HomeScreenBuilderInput {
}

protocol HomeScreenCallback {
}

enum HomeScreenResult: Equatable {
    case partialState(_ value: HomeScreenPartialState)
    case effect(_ value: HomeScreenEffect)
}

enum HomeScreenPartialState: Equatable {
    case updateWorkoutsHistory(workouts: [FinishedWorkout])
    func reduce(previousState: HomeScreenViewState) -> HomeScreenViewState {
        var state = previousState
        switch self {
        case .updateWorkoutsHistory(workouts: let workouts):
            state.workoutsHistory = workouts
        }
        return state
    }
}

protocol HomeScreenBuilder {
    func build(with input: HomeScreenBuilderInput) -> HomeScreenModule
}

struct HomeScreenModule {
    let view: HomeScreenView
    let callback: HomeScreenCallback
}

protocol HomeScreenView: BaseView {
    var intents: Observable<HomeScreenIntent> { get }
    func render(state: HomeScreenViewState)
}

protocol HomeScreenPresenter: AnyObject, BasePresenter {
    func bindIntents(view: HomeScreenView, triggerEffect: PublishSubject<HomeScreenEffect>) -> Observable<HomeScreenViewState>
}

protocol HomeScreenInteractor: BaseInteractor {
    func subscribeForWorkoutsHistory() -> Observable<HomeScreenResult>
}

protocol HomeScreenMiddleware {
    var middlewareObservable: Observable<HomeScreenResult> { get }
    func process(result: HomeScreenResult) -> Observable<HomeScreenResult>
}
