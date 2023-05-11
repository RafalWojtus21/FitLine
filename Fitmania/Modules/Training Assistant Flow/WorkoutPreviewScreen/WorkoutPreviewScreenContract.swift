//
//  WorkoutPreviewScreenContract.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 10/05/2023.
//

import RxSwift

enum WorkoutPreviewScreenIntent {
}

struct WorkoutPreviewScreenViewState: Equatable {
    let chosenWorkout: WorkoutPlan
}

enum WorkoutPreviewScreenEffect: Equatable {
}

struct WorkoutPreviewScreenBuilderInput {
    let chosenWorkout: WorkoutPlan
}

protocol WorkoutPreviewScreenCallback {
}

enum WorkoutPreviewScreenResult: Equatable {
    case partialState(_ value: WorkoutPreviewScreenPartialState)
    case effect(_ value: WorkoutPreviewScreenEffect)
}

enum WorkoutPreviewScreenPartialState: Equatable {
    func reduce(previousState: WorkoutPreviewScreenViewState) -> WorkoutPreviewScreenViewState {
        let state = previousState
        return state
    }
}

protocol WorkoutPreviewScreenBuilder {
    func build(with input: WorkoutPreviewScreenBuilderInput) -> WorkoutPreviewScreenModule
}

struct WorkoutPreviewScreenModule {
    let view: WorkoutPreviewScreenView
    let callback: WorkoutPreviewScreenCallback
}

protocol WorkoutPreviewScreenView: BaseView {
    var intents: Observable<WorkoutPreviewScreenIntent> { get }
    func render(state: WorkoutPreviewScreenViewState)
}

protocol WorkoutPreviewScreenPresenter: AnyObject, BasePresenter {
    func bindIntents(view: WorkoutPreviewScreenView, triggerEffect: PublishSubject<WorkoutPreviewScreenEffect>) -> Observable<WorkoutPreviewScreenViewState>
}

protocol WorkoutPreviewScreenInteractor: BaseInteractor {
}

protocol WorkoutPreviewScreenMiddleware {
    var middlewareObservable: Observable<WorkoutPreviewScreenResult> { get }
    func process(result: WorkoutPreviewScreenResult) -> Observable<WorkoutPreviewScreenResult>
}
