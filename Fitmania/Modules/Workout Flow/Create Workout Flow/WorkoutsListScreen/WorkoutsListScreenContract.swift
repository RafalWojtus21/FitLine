//
//  WorkoutsListScreenContract.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 20/04/2023.
//

import RxSwift

enum WorkoutsListScreenIntent {
    case plusButtonIntent
    case createNewTraining(name: String)
    case loadTrainingPlans
}

struct WorkoutsListScreenViewState: Equatable {
    var workouts: [WorkoutPlan] = []
}

enum WorkoutsListScreenEffect: Equatable {
    case nameCustomWorkoutAlert
    case showWorkoutCategoryListScreen
    case showNewTrainingPlanScreen(name: String)
}

struct WorkoutsListScreenBuilderInput {
}

protocol WorkoutsListScreenCallback {
}

enum WorkoutsListScreenResult: Equatable {
    case partialState(_ value: WorkoutsListScreenPartialState)
    case effect(_ value: WorkoutsListScreenEffect)
}

enum WorkoutsListScreenPartialState: Equatable {
    case updateTrainingPlans(plans: [WorkoutPlan])
    
    func reduce(previousState: WorkoutsListScreenViewState) -> WorkoutsListScreenViewState {
        var state = previousState
        switch self {
        case .updateTrainingPlans(plans: let plans):
            state.workouts = plans
        }
        return state
    }
}

protocol WorkoutsListScreenBuilder {
    func build(with input: WorkoutsListScreenBuilderInput) -> WorkoutsListScreenModule
}

struct WorkoutsListScreenModule {
    let view: WorkoutsListScreenView
    let callback: WorkoutsListScreenCallback
}

protocol WorkoutsListScreenView: BaseView {
    var intents: Observable<WorkoutsListScreenIntent> { get }
    func render(state: WorkoutsListScreenViewState)
}

protocol WorkoutsListScreenPresenter: AnyObject, BasePresenter {
    func bindIntents(view: WorkoutsListScreenView, triggerEffect: PublishSubject<WorkoutsListScreenEffect>) -> Observable<WorkoutsListScreenViewState>
}

protocol WorkoutsListScreenInteractor: BaseInteractor {
    func loadTrainingPlans() -> Observable<WorkoutsListScreenResult>
}

protocol WorkoutsListScreenMiddleware {
    var middlewareObservable: Observable<WorkoutsListScreenResult> { get }
    func process(result: WorkoutsListScreenResult) -> Observable<WorkoutsListScreenResult>
}
