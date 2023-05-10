//
//  WorkoutsListScreenMiddleware.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 20/04/2023.
//

import RxSwift

final class WorkoutsListScreenMiddlewareImpl: WorkoutsListScreenMiddleware, WorkoutsListScreenCallback {
    typealias Dependencies = HasWorkoutFlowNavigation
    typealias Result = WorkoutsListScreenResult
    
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
            case .showNewTrainingPlanScreen(name: let name):
                dependencies.workoutFlowNavigation?.startCreateWorkoutFlow(trainingName: name)
            case .showScheduleWorkoutScreen(plan: let plan):
                dependencies.workoutFlowNavigation?.startTrainingAssistantFlow(plan: plan)
            default: break
            }
        }
        return .just(result)
    }
}
