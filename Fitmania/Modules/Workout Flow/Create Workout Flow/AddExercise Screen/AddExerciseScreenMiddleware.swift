//
//  AddExerciseScreenMiddleware.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 25/04/2023.
//

import RxSwift

final class AddExerciseScreenMiddlewareImpl: AddExerciseScreenMiddleware, AddExerciseScreenCallback {
    typealias Dependencies = HasCreateWorkoutFlow
    typealias Result = AddExerciseScreenResult
    
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
            case .exerciseAdded:
                dependencies.createWorkoutFlowNavigation?.popToRootViewController()
            case .somethingWentWrong:
                break
            case .invalidData:
                break
            }
        }
        return .just(result)
    }
}
