//
//  ScheduleWorkoutScreenContract.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 10/05/2023.
//

import RxSwift
import UIKit

enum ScheduleWorkoutScreenIntent {
    case viewLoaded
    case startNowButtonIntent
    case workoutPreviewTapped
    case scheduleWorkoutIntent(date: Date)
    case showDateTimePickerIntent
    case editWorkout
}

struct ScheduleWorkoutScreenViewState: Equatable {
    let chosenWorkout: WorkoutPlan
    var totalWorkoutTimeInSeconds: Int?
    var totalWorkoutTimeInMinutes: Int?
    var totalNumberOfSets: Int?
    var categories: [Exercise.Category] = []
}

enum ScheduleWorkoutScreenEffect: Equatable {
    case startNowButtonPressed
    case showWorkoutPreview
    case workoutScheduled
    case workoutScheduleError
    case showDateTimePicker(workoutName: String)
    case editWorkout
}

struct ScheduleWorkoutScreenBuilderInput {
    let chosenWorkout: WorkoutPlan
}

protocol ScheduleWorkoutScreenCallback {
}

enum ScheduleWorkoutScreenResult: Equatable {
    case partialState(_ value: ScheduleWorkoutScreenPartialState)
    case effect(_ value: ScheduleWorkoutScreenEffect)
}

enum ScheduleWorkoutScreenPartialState: Equatable {
    case updateWorkoutInfo(totalWorkoutTimeInSeconds: Int, totalWorkoutTimeInMinutes: Int, totalNumberOfSets: Int, categories: [Exercise.Category])
    case idle
    func reduce(previousState: ScheduleWorkoutScreenViewState) -> ScheduleWorkoutScreenViewState {
        var state = previousState
        switch self {
        case .updateWorkoutInfo(totalWorkoutTimeInSeconds: let totalWorkoutTimeInSeconds, totalWorkoutTimeInMinutes: let totalWorkoutTimeInMinutes, totalNumberOfSets: let totalNumberOfSets, categories: let categories):
            state.totalWorkoutTimeInSeconds = totalWorkoutTimeInSeconds
            state.totalWorkoutTimeInMinutes = totalWorkoutTimeInMinutes
            state.totalNumberOfSets = totalNumberOfSets
            state.categories = categories
        case .idle:
            break
        }
        return state
    }
}

protocol ScheduleWorkoutScreenBuilder {
    func build(with input: ScheduleWorkoutScreenBuilderInput) -> ScheduleWorkoutScreenModule
}

struct ScheduleWorkoutScreenModule {
    let view: ScheduleWorkoutScreenView
    let callback: ScheduleWorkoutScreenCallback
}

protocol ScheduleWorkoutScreenView: BaseView {
    var intents: Observable<ScheduleWorkoutScreenIntent> { get }
    func render(state: ScheduleWorkoutScreenViewState)
}

protocol ScheduleWorkoutScreenPresenter: AnyObject, BasePresenter {
    func bindIntents(view: ScheduleWorkoutScreenView, triggerEffect: PublishSubject<ScheduleWorkoutScreenEffect>) -> Observable<ScheduleWorkoutScreenViewState>
}

protocol ScheduleWorkoutScreenInteractor: BaseInteractor {
    func calculateWorkoutDetails() -> Observable<ScheduleWorkoutScreenResult>
    func scheduleWorkoutNotification(for date: Date) -> Observable<ScheduleWorkoutScreenResult>
}

protocol ScheduleWorkoutScreenMiddleware {
    var middlewareObservable: Observable<ScheduleWorkoutScreenResult> { get }
    func process(result: ScheduleWorkoutScreenResult) -> Observable<ScheduleWorkoutScreenResult>
}
