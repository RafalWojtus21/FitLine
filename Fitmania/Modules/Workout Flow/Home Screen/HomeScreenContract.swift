//
//  HomeScreenContract.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 19/04/2023.
//

import RxSwift
import Foundation

enum HomeScreen {
    struct PersonalRecordData: Equatable {
        let score: Float
        let date: Date
    }
}

enum HomeScreenIntent {
    case viewLoaded
    case startWorkoutButtonIntent
    case showWorkoutSummaryIntent(workout: FinishedWorkout)
}

struct HomeScreenViewState: Equatable {
    var workoutsHistory: [FinishedWorkout] = []
    var userInfo: UserInfo?
    var personalRecordsDictionary: [Exercise: HomeScreen.PersonalRecordData] = [:]
    var shouldUpdatePersonalRecords = false
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
    case setUserInfo(userInfo: UserInfo)
    case setPersonalRecords(personalRecords: [Exercise: HomeScreen.PersonalRecordData])
    func reduce(previousState: HomeScreenViewState) -> HomeScreenViewState {
        var state = previousState
        state.shouldUpdatePersonalRecords = false
        switch self {
        case .updateWorkoutsHistory(workouts: let workouts):
            state.workoutsHistory = workouts
        case .setUserInfo(userInfo: let userInfo):
            state.userInfo = userInfo
        case .setPersonalRecords(personalRecords: let personalRecords):
            state.shouldUpdatePersonalRecords = true
            state.personalRecordsDictionary = personalRecords
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
    func fetchUserInfo() -> Observable<HomeScreenResult>
    func subscribeForWorkoutsHistory() -> Observable<HomeScreenResult>
    func setPersonalRecords() -> Observable<HomeScreenResult>
}

protocol HomeScreenMiddleware {
    var middlewareObservable: Observable<HomeScreenResult> { get }
    func process(result: HomeScreenResult) -> Observable<HomeScreenResult>
}
