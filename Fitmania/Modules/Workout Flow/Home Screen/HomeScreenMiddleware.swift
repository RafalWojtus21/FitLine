//
//  HomeScreenMiddleware.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 19/04/2023.
//

import RxSwift

final class HomeScreenMiddlewareImpl: HomeScreenMiddleware, HomeScreenCallback {
    typealias Dependencies = HasWorkoutFlowNavigation
    typealias Result = HomeScreenResult
    
    private let dependencies: Dependencies

    private let middlewareSubject = PublishSubject<Result>()
    var middlewareObservable: Observable<Result> { return middlewareSubject }
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    func process(result: Result) -> Observable<Result> {
        switch result {
        case .partialState(_): break
        case .effect(let effect):
            switch effect {
            case .showWorkoutsList:
                dependencies.workoutFlowNavigation?.showWorkoutsListScreen()
            case .showWorkoutSummaryScreen(workout: let workout):
                dependencies.workoutFlowNavigation?.showWorkoutSummaryScreen(workout: workout, shouldSaveWorkout: false)
            }
        }
        return .just(result)
    }
}
