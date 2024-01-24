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
    case nextButtonIntent(details: [String])
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
    var isPauseButtonVisible: Bool { intervalState != .paused && intervalState != .notStarted && !shouldShowStrengthExerciseAnimation }
    var isResumeButtonVisible: Bool { intervalState == .paused && !shouldShowStrengthExerciseAnimation }
    var isPauseButtonEnabled: Bool { intervalState == .running }
    var isResumeButtonEnabled: Bool { intervalState == .paused }
    var shouldChangeTable = false
    var shouldChangeEventName: Bool { workoutEvents.count > 0 && intervalState != .notStarted}
    var shouldShowTimer = false
    var shouldShowStrengthExerciseAnimation = false
    var shouldTriggerAnimation = false
    var possibleDetailsTypes: [Exercise.DetailsType] = []
    var shouldRefreshDetailsTextField = false
    var shouldChangeAnimation = false
    var animationDuration: Int?
}

enum WorkoutExerciseScreenEffect: Equatable {
    case workoutFinished(finishedWorkout: FinishedWorkout)
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
    case updateCurrentTime(intervalState: WorkoutExerciseScreen.IntervalState, previousProgress: Float, currentProgress: Float, timeLeft: Int)
    case loadWorkoutEvents(workoutEvents: [WorkoutPartEvent])
    case isTimerRunning(isRunning: Bool)
    case updateIntervalState(intervalState: WorkoutExerciseScreen.IntervalState)
    case idle
    case switchToPhysicalExerciseView(currentEventIndex: Int)
    case shouldShowTimer(isTimerVisible: Bool)
    case triggerAnimation
    case updateCurrentEventIndex(currentEventIndex: Int)
    case updateAvailableDetailsTypes(detailsTypes: [Exercise.DetailsType])
    case setAnimationDuration(duration: Int)
    func reduce(previousState: WorkoutExerciseScreenViewState) -> WorkoutExerciseScreenViewState {
        var state = previousState
        state.shouldChangeTable = false
        state.shouldRefreshDetailsTextField = false
        state.shouldChangeAnimation = false
        switch self {
        case .updateCurrentTime(let intervalState, let previousProgress, let currentProgress, let timeLeft):
            state.intervalState = intervalState
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
        case .switchToPhysicalExerciseView(currentEventIndex: let currentEventIndex):
            state.currentEventIndex = currentEventIndex
        case .shouldShowTimer(isTimerVisible: let isTimerVisible):
            state.shouldShowTimer = isTimerVisible
            state.shouldShowStrengthExerciseAnimation = !isTimerVisible
        case .triggerAnimation:
            state.shouldTriggerAnimation = true
        case .updateCurrentEventIndex(currentEventIndex: let currentEventIndex):
            state.currentEventIndex = currentEventIndex
            state.workoutEvents = state.workoutEvents.enumerated().compactMap({ index, row in
                WorkoutExerciseScreen.Row(event: row.event, isSelected: index == currentEventIndex)
            })
            state.shouldChangeTable = true
            state.shouldChangeAnimation = true
        case .updateAvailableDetailsTypes(detailsTypes: let detailsTypes):
            state.possibleDetailsTypes = detailsTypes
            state.shouldRefreshDetailsTextField = true
        case .setAnimationDuration(duration: let duration):
            state.animationDuration = duration
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
