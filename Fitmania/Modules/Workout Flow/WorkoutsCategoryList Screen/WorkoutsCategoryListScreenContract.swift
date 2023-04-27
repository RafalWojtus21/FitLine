//
//  WorkoutsCategoryListScreenContract.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 25/04/2023.
//

import RxSwift

enum WorkoutsCategoryListScreenIntent {
    case cellTapped(category: Exercise.ExerciseCategory)
}

struct WorkoutsCategoryListScreenViewState: Equatable {
    var categories = Exercise.ExerciseCategory.allCases
}

enum WorkoutsCategoryListScreenEffect: Equatable {
    case showCategoryExercisesList(category: Exercise.ExerciseCategory)
}

struct WorkoutsCategoryListScreenBuilderInput {
}

protocol WorkoutsCategoryListScreenCallback {
}

enum WorkoutsCategoryListScreenResult: Equatable {
    case partialState(_ value: WorkoutsCategoryListScreenPartialState)
    case effect(_ value: WorkoutsCategoryListScreenEffect)
}

enum WorkoutsCategoryListScreenPartialState: Equatable {
    func reduce(previousState: WorkoutsCategoryListScreenViewState) -> WorkoutsCategoryListScreenViewState {
        let state = previousState
        return state
    }
}

protocol WorkoutsCategoryListScreenBuilder {
    func build(with input: WorkoutsCategoryListScreenBuilderInput) -> WorkoutsCategoryListScreenModule
}

struct WorkoutsCategoryListScreenModule {
    let view: WorkoutsCategoryListScreenView
    let callback: WorkoutsCategoryListScreenCallback
}

protocol WorkoutsCategoryListScreenView: BaseView {
    var intents: Observable<WorkoutsCategoryListScreenIntent> { get }
    func render(state: WorkoutsCategoryListScreenViewState)
}

protocol WorkoutsCategoryListScreenPresenter: AnyObject, BasePresenter {
    func bindIntents(view: WorkoutsCategoryListScreenView, triggerEffect: PublishSubject<WorkoutsCategoryListScreenEffect>) -> Observable<WorkoutsCategoryListScreenViewState>
}

protocol WorkoutsCategoryListScreenInteractor: BaseInteractor {
}

protocol WorkoutsCategoryListScreenMiddleware {
    var middlewareObservable: Observable<WorkoutsCategoryListScreenResult> { get }
    func process(result: WorkoutsCategoryListScreenResult) -> Observable<WorkoutsCategoryListScreenResult>
}
