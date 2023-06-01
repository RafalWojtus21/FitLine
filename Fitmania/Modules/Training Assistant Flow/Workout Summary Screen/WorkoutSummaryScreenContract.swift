//
//  WorkoutFinishedScreenContract.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 17/05/2023.
//

import RxSwift
import Foundation

enum WorkoutSummaryScreen {
    
    struct WorkoutSummaryPart: Equatable {
        enum EventType {
            case exercise
            case rest
        }
        let type: EventType
        let name: String
        let duration: Int
    }
    
    enum SavingStatus {
        case saved
        case notSaved
        case notNeeded
    }
}

enum WorkoutSummaryScreenIntent {
    case viewLoaded
    case doneButtonPressed
}

struct WorkoutSummaryScreenViewState: Equatable {
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
    var savingStatus: WorkoutSummaryScreen.SavingStatus = .notSaved
    var isWorkoutSaved: Bool {
        switch savingStatus {
        case .notSaved:
            return false
        default:
            return true
        }
    }
    var workoutSummary: [WorkoutSummaryModel] = []
    let shouldSaveWorkout: Bool
}

enum WorkoutSummaryScreenEffect: Equatable {
    case doneButtonEffect
    case workoutSaved
    case somethingWentWrong
}

struct WorkoutSummaryScreenBuilderInput {
    let workoutDoneModel: FinishedWorkout
    let shouldSaveWorkout: Bool
}

protocol WorkoutSummaryScreenCallback {
}

enum WorkoutSummaryScreenResult: Equatable {
    case partialState(_ value: WorkoutSummaryScreenPartialState)
    case effect(_ value: WorkoutSummaryScreenEffect)
}

enum WorkoutSummaryScreenPartialState: Equatable {
    case isWorkoutSaved(savingStatus: WorkoutSummaryScreen.SavingStatus)
    case calculateWorkoutSummaryModel(workoutSummaryModel: [WorkoutSummaryModel])
    case idle
    func reduce(previousState: WorkoutSummaryScreenViewState) -> WorkoutSummaryScreenViewState {
        var state = previousState
        switch self {
        case .calculateWorkoutSummaryModel(workoutSummaryModel: let workoutSummaryModel):
            state.workoutSummary = workoutSummaryModel
        case .idle:
            break
        case .isWorkoutSaved(savingStatus: let savingStatus):
            state.savingStatus = savingStatus
        }
        return state
    }
}

protocol WorkoutSummaryScreenBuilder {
    func build(with input: WorkoutSummaryScreenBuilderInput) -> WorkoutSummaryScreenModule
}

struct WorkoutSummaryScreenModule {
    let view: WorkoutSummaryScreenView
    let callback: WorkoutSummaryScreenCallback
}

protocol WorkoutSummaryScreenView: BaseView {
    var intents: Observable<WorkoutSummaryScreenIntent> { get }
    func render(state: WorkoutSummaryScreenViewState)
}

protocol WorkoutSummaryScreenPresenter: AnyObject, BasePresenter {
    func bindIntents(view: WorkoutSummaryScreenView, triggerEffect: PublishSubject<WorkoutSummaryScreenEffect>) -> Observable<WorkoutSummaryScreenViewState>
}

protocol WorkoutSummaryScreenInteractor: BaseInteractor {
    func saveWorkoutToHistory() -> Observable<WorkoutSummaryScreenResult>
    func calculateWorkoutSummaryModels() -> Observable<WorkoutSummaryScreenResult>
}

protocol WorkoutSummaryScreenMiddleware {
    var middlewareObservable: Observable<WorkoutSummaryScreenResult> { get }
    func process(result: WorkoutSummaryScreenResult) -> Observable<WorkoutSummaryScreenResult>
}
