//
//  WorkoutsCategoryListScreenMiddleware.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 25/04/2023.
//

import RxSwift

final class WorkoutsCategoryListScreenMiddlewareImpl: WorkoutsCategoryListScreenMiddleware, WorkoutsCategoryListScreenCallback {
    typealias Dependencies = HasCreateWorkoutFlow
    typealias Result = WorkoutsCategoryListScreenResult
    
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
            case .showCategoryExercisesList(category: let category):
                dependencies.createWorkoutFlowNavigation?.showCategoryExercisesListScreen(category: category)
            }
        }
        return .just(result)
    }
}
