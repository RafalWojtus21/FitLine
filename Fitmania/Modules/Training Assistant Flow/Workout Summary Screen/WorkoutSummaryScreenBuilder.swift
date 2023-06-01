//
//  WorkoutFinishedScreenBuilder.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 17/05/2023.
//

import UIKit
import RxSwift

final class WorkoutSummaryScreenBuilderImpl: WorkoutSummaryScreenBuilder {
    typealias Dependencies = WorkoutSummaryScreenInteractorImpl.Dependencies & WorkoutSummaryScreenMiddlewareImpl.Dependencies
    private let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
        
    func build(with input: WorkoutSummaryScreenBuilderInput) -> WorkoutSummaryScreenModule {
        let interactor = WorkoutSummaryScreenInteractorImpl(dependencies: dependencies, input: input)
        let middleware = WorkoutSummaryScreenMiddlewareImpl(dependencies: dependencies)
        let presenter = WorkoutSummaryScreenPresenterImpl(interactor: interactor, middleware: middleware, initialViewState: WorkoutSummaryScreenViewState(workoutDoneModel: input.workoutDoneModel, shouldSaveWorkout: input.shouldSaveWorkout))
        let view = WorkoutSummaryScreenViewController(presenter: presenter)
        return WorkoutSummaryScreenModule(view: view, callback: middleware)
    }
}
