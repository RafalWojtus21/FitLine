//
//  WorkoutExerciseScreenContract.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 11/05/2023.
//

import RxSwift
import UIKit

enum WorkoutExerciseScreen {
    
    struct Row: Equatable {
        let event: WorkoutPartEvent
        let isSelected: Bool
    }
    
    enum IntervalState {
        case notStarted
        case running
        case paused
        case finished
    }
}

enum WorkoutExerciseScreenIntent {
    case viewLoaded
    case startEventIntent
    case pauseButtonIntent
    case resumeButtonIntent
    case nextEventButtonIntent
    case plusButtonIntent
    case saveButtonPressed(details: [String])
}

struct WorkoutExerciseScreenViewState: Equatable {
    let chosenPlan: WorkoutPlan
    var workoutEvents: [WorkoutExerciseScreen.Row] = []
    var currentEventIndex: Int = 0
    var currentProgress: Float = 0.0
    var previousProgress: Float = 0.0
    var timeLeft: Int
    var intervalState: WorkoutExerciseScreen.IntervalState = .notStarted
    var isTimerRunning = true
    var isStartButtonVisible: Bool { intervalState == .notStarted }
    var isNextButtonVisible: Bool { !isStartButtonVisible }
    var isPauseButtonVisible: Bool { intervalState != .paused && intervalState != .notStarted }
    var isResumeButtonVisible: Bool { intervalState == .paused }
    var isPauseButtonEnabled: Bool { intervalState == .running }
    var isResumeButtonEnabled: Bool { intervalState == .paused }
    var shouldChangeTable = false
    var shouldChangeEventName: Bool { workoutEvents.count > 0 }
}

enum WorkoutExerciseScreenEffect: Equatable {
    case workoutFinished(finishedWorkout: FinishedWorkout)
    case showExerciseDetailsAlert(detailsTypes: [Exercise.DetailsType])
    case somethingWentWrong
}

struct WorkoutExerciseScreenBuilderInput {
    let chosenPlan: WorkoutPlan
}

protocol WorkoutExerciseScreenCallback {
}

enum WorkoutExerciseScreenResult: Equatable {
    case partialState(_ value: WorkoutExerciseScreenPartialState)
    case effect(_ value: WorkoutExerciseScreenEffect)
}

enum WorkoutExerciseScreenPartialState: Equatable {
    case updateCurrentTime(intervalState: WorkoutExerciseScreen.IntervalState, currentEventIndex: Int, previousProgress: Float, currentProgress: Float, timeLeft: Int)
    case loadWorkoutEvents(workoutEvents: [WorkoutPartEvent])
    case isTimerRunning(isRunning: Bool)
    case updateIntervalState(intervalState: WorkoutExerciseScreen.IntervalState)
    case idle
    func reduce(previousState: WorkoutExerciseScreenViewState) -> WorkoutExerciseScreenViewState {
        var state = previousState
        state.shouldChangeTable = false
        switch self {
        case .updateCurrentTime(let intervalState, let currentEventIndex, let previousProgress, let currentProgress, let timeLeft):
            state.intervalState = intervalState
            state.currentEventIndex = currentEventIndex
            state.workoutEvents = state.workoutEvents.enumerated().compactMap({ index, row in
                WorkoutExerciseScreen.Row(event: row.event, isSelected: index == currentEventIndex)
            })
            state.shouldChangeTable = true
            state.currentProgress = currentProgress
            state.previousProgress = previousProgress
            state.timeLeft = timeLeft
        case .isTimerRunning(isRunning: let isRunning):
            state.isTimerRunning = isRunning
        case .loadWorkoutEvents(workoutEvents: let workoutEvents):
            state.workoutEvents = workoutEvents.compactMap({ event in
                WorkoutExerciseScreen.Row(event: event, isSelected: false)
            })
            state.shouldChangeTable = true
        case .idle:
            break
        case .updateIntervalState(intervalState: let intervalState):
            state.intervalState = intervalState
        }
        return state
    }
}

protocol WorkoutExerciseScreenBuilder {
    func build(with input: WorkoutExerciseScreenBuilderInput) -> WorkoutExerciseScreenModule
}

struct WorkoutExerciseScreenModule {
    let view: WorkoutExerciseScreenView
    let callback: WorkoutExerciseScreenCallback
}

protocol WorkoutExerciseScreenView: BaseView {
    var intents: Observable<WorkoutExerciseScreenIntent> { get }
    func render(state: WorkoutExerciseScreenViewState)
}

protocol WorkoutExerciseScreenPresenter: AnyObject, BasePresenter {
    func bindIntents(view: WorkoutExerciseScreenView, triggerEffect: PublishSubject<WorkoutExerciseScreenEffect>) -> Observable<WorkoutExerciseScreenViewState>
}

protocol WorkoutExerciseScreenInteractor: BaseInteractor {
    func loadEvents() -> Observable<WorkoutExerciseScreenResult>
    func observeForExercises() -> Observable<WorkoutExerciseScreenResult>
    func triggerFirstExercise() -> Observable<WorkoutExerciseScreenResult>
    func triggerNextExercise() -> Observable<WorkoutExerciseScreenResult>
    func setTimer() -> Observable<WorkoutExerciseScreenResult>
    func pauseTimer() -> Observable<WorkoutExerciseScreenResult>
    func resumeTimer() -> Observable<WorkoutExerciseScreenResult>
    func getCurrentExercise() -> Observable<WorkoutExerciseScreenResult>
    func saveDetailOfCurrentExercise(details: [String]) -> Observable<WorkoutExerciseScreenResult>
}

protocol WorkoutExerciseScreenMiddleware {
    var middlewareObservable: Observable<WorkoutExerciseScreenResult> { get }
    func process(result: WorkoutExerciseScreenResult) -> Observable<WorkoutExerciseScreenResult>
}
