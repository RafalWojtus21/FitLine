//
//  WorkoutFinishedScreenContract.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 17/05/2023.
//

import RxSwift
import Foundation

enum WorkoutFinishedScreen {
    
    struct WorkoutSummaryPart: Equatable {
        enum EventType {
            case exercise
            case rest
        }
        let type: EventType
        let name: String
        let duration: Int
    }
}

enum WorkoutFinishedScreenIntent {
    case viewLoaded
    case doneButtonPressed
}

struct WorkoutFinishedScreenViewState: Equatable {
    let workoutDoneModel: FinishedWorkout
    var exerciseNames: [String] {
        workoutDoneModel.exercisesDetails.map { $0.exercise.name }
    }
    var workoutDayLabelText: String {
        DateFormatter.dayMonthStringDateFormatter.string(from: workoutDoneModel.startDate)
    }
    var workoutHoursLabelText: String {
        let dateFormatter = DateFormatter.hourMinuteDateFormatter
        return "\(dateFormatter.string(from: workoutDoneModel.startDate)) - \(dateFormatter.string(from: workoutDoneModel.finishDate))"
    }
    var isWorkoutSaved = false
}

enum WorkoutFinishedScreenEffect: Equatable {
    case doneButtonEffect
    case workoutSaved
    case somethingWentWrong
}

struct WorkoutFinishedScreenBuilderInput {
    let workoutDoneModel: FinishedWorkout
}

protocol WorkoutFinishedScreenCallback {
}

enum WorkoutFinishedScreenResult: Equatable {
    case partialState(_ value: WorkoutFinishedScreenPartialState)
    case effect(_ value: WorkoutFinishedScreenEffect)
}

enum WorkoutFinishedScreenPartialState: Equatable {
    case isWorkoutSaved(isSaved: Bool)
    func reduce(previousState: WorkoutFinishedScreenViewState) -> WorkoutFinishedScreenViewState {
        var state = previousState
        switch self {
        case .isWorkoutSaved(isSaved: let isSaved):
            state.isWorkoutSaved = isSaved
        }
        return state
    }
}

protocol WorkoutFinishedScreenBuilder {
    func build(with input: WorkoutFinishedScreenBuilderInput) -> WorkoutFinishedScreenModule
}

struct WorkoutFinishedScreenModule {
    let view: WorkoutFinishedScreenView
    let callback: WorkoutFinishedScreenCallback
}

protocol WorkoutFinishedScreenView: BaseView {
    var intents: Observable<WorkoutFinishedScreenIntent> { get }
    func render(state: WorkoutFinishedScreenViewState)
}

protocol WorkoutFinishedScreenPresenter: AnyObject, BasePresenter {
    func bindIntents(view: WorkoutFinishedScreenView, triggerEffect: PublishSubject<WorkoutFinishedScreenEffect>) -> Observable<WorkoutFinishedScreenViewState>
}

protocol WorkoutFinishedScreenInteractor: BaseInteractor {
    func saveWorkoutToHistory() -> Observable<WorkoutFinishedScreenResult>
}

protocol WorkoutFinishedScreenMiddleware {
    var middlewareObservable: Observable<WorkoutFinishedScreenResult> { get }
    func process(result: WorkoutFinishedScreenResult) -> Observable<WorkoutFinishedScreenResult>
}
