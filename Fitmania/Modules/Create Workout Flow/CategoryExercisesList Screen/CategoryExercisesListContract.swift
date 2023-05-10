//
//  CategoryExercisesListContract.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 25/04/2023.
//

import RxSwift

enum CategoryExercisesListIntent {
    case viewLoaded
    case cellTapped(chosenExercise: Exercise)
}

struct CategoryExercisesListViewState: Equatable {
    let chosenCategory: Exercise.Category
    var exercises: [Exercise] = []
}

enum CategoryExercisesListEffect: Equatable {
    case somethingWentWrong
    case showAddExerciseScreen(exercise: Exercise)
}

struct CategoryExercisesListBuilderInput {
    let chosenCategory: Exercise.Category
}

protocol CategoryExercisesListCallback {
}

enum CategoryExercisesListResult: Equatable {
    case partialState(_ value: CategoryExercisesListPartialState)
    case effect(_ value: CategoryExercisesListEffect)
}

enum CategoryExercisesListPartialState: Equatable {
    case loadExercises(exercises: [Exercise])
    func reduce(previousState: CategoryExercisesListViewState) -> CategoryExercisesListViewState {
        var state = previousState
        switch self {
        case .loadExercises(exercises: let exercises):
            state.exercises = exercises
        }
        return state
    }
}

protocol CategoryExercisesListBuilder {
    func build(with input: CategoryExercisesListBuilderInput) -> CategoryExercisesListModule
}

struct CategoryExercisesListModule {
    let view: CategoryExercisesListView
    let callback: CategoryExercisesListCallback
}

protocol CategoryExercisesListView: BaseView {
    var intents: Observable<CategoryExercisesListIntent> { get }
    func render(state: CategoryExercisesListViewState)
}

protocol CategoryExercisesListPresenter: AnyObject, BasePresenter {
    func bindIntents(view: CategoryExercisesListView, triggerEffect: PublishSubject<CategoryExercisesListEffect>) -> Observable<CategoryExercisesListViewState>
}

protocol CategoryExercisesListInteractor: BaseInteractor {
    func loadExercises() -> Observable<CategoryExercisesListResult>
}

protocol CategoryExercisesListMiddleware {
    var middlewareObservable: Observable<CategoryExercisesListResult> { get }
    func process(result: CategoryExercisesListResult) -> Observable<CategoryExercisesListResult>
}
