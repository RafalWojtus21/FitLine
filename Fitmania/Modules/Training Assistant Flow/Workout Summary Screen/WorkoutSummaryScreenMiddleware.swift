//
//  WorkoutFinishedScreenMiddleware.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 17/05/2023.
//

import RxSwift

final class WorkoutSummaryScreenMiddlewareImpl: WorkoutSummaryScreenMiddleware, WorkoutSummaryScreenCallback {
    typealias Dependencies = HasTrainingAssistantFlowNavigation
    typealias Result = WorkoutSummaryScreenResult
    
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
            case .doneButtonEffect:
                dependencies.trainingAssistantFlowNavigation?.finishTrainingAssistantFlow()
            default: break
            }
        }
        return .just(result)
    }
}
