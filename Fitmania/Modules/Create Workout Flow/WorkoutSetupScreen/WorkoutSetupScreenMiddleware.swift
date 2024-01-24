//
//  WorkoutSetupScreenMiddleware.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 25/04/2023.
//

import RxSwift

final class WorkoutSetupScreenMiddlewareImpl: WorkoutSetupScreenMiddleware, WorkoutSetupScreenCallback {
    typealias Dependencies = HasCreateWorkoutFlow
    typealias Result = WorkoutSetupScreenResult
    
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
            case .showWorkoutsCategoryListScreen:
                dependencies.createWorkoutFlowNavigation?.showWorkoutCategoryListScreen()
            case .workoutSaved:
                dependencies.createWorkoutFlowNavigation?.finishCreateWorkoutFlow()
            case .editExercise(workoutPart: let workoutPart):
                dependencies.createWorkoutFlowNavigation?.showEditExerciseScreen(workoutPart)
            default:
                break
            }
        }
        return .just(result)
    }
}
