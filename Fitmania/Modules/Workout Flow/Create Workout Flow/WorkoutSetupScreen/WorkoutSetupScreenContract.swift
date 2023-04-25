//
//  WorkoutSetupScreenContract.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 25/04/2023.
//

import RxSwift

enum WorkoutSetupScreenIntent {
    case viewLoaded
    case addExerciseButtonIntent
    case saveButtonPressed
}

struct WorkoutSetupScreenViewState: Equatable {
    var trainingName: String
    var exercises: [WorkoutPart] = []
}

enum WorkoutSetupScreenEffect: Equatable {
    case showWorkoutsCategoryListScreen
    case workoutNameSet
    case workoutSaved
    case somethingWentWrong
}

struct WorkoutSetupScreenBuilderInput {
    var trainingName: String
}

protocol WorkoutSetupScreenCallback {
}

enum WorkoutSetupScreenResult: Equatable {
    case partialState(_ value: WorkoutSetupScreenPartialState)
    case effect(_ value: WorkoutSetupScreenEffect)
}

enum WorkoutSetupScreenPartialState: Equatable {
    case loadExercises(exercises: [WorkoutPart])
    func reduce(previousState: WorkoutSetupScreenViewState) -> WorkoutSetupScreenViewState {
        var state = previousState
        switch self {
        case .loadExercises(let exercises):
            state.exercises = exercises
        }
        return state
    }
}

protocol WorkoutSetupScreenBuilder {
    func build(with input: WorkoutSetupScreenBuilderInput) -> WorkoutSetupScreenModule
}

struct WorkoutSetupScreenModule {
    let view: WorkoutSetupScreenView
    let callback: WorkoutSetupScreenCallback
}

protocol WorkoutSetupScreenView: BaseView {
    var intents: Observable<WorkoutSetupScreenIntent> { get }
    func render(state: WorkoutSetupScreenViewState)
}

protocol WorkoutSetupScreenPresenter: AnyObject, BasePresenter {
    func bindIntents(view: WorkoutSetupScreenView, triggerEffect: PublishSubject<WorkoutSetupScreenEffect>) -> Observable<WorkoutSetupScreenViewState>
}

protocol WorkoutSetupScreenInteractor: BaseInteractor {
    func loadExercises() -> Observable<WorkoutSetupScreenResult>
    func setWorkoutData() -> Observable<WorkoutSetupScreenResult>
    func saveWorkoutToDatabase() -> Observable<WorkoutSetupScreenResult>
}

protocol WorkoutSetupScreenMiddleware {
    var middlewareObservable: Observable<WorkoutSetupScreenResult> { get }
    func process(result: WorkoutSetupScreenResult) -> Observable<WorkoutSetupScreenResult>
}
