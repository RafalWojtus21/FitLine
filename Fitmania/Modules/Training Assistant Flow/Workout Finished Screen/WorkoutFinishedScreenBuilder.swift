//
//  WorkoutFinishedScreenBuilder.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 17/05/2023.
//

import UIKit
import RxSwift

final class WorkoutFinishedScreenBuilderImpl: WorkoutFinishedScreenBuilder {
    typealias Dependencies = WorkoutFinishedScreenInteractorImpl.Dependencies & WorkoutFinishedScreenMiddlewareImpl.Dependencies
    private let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
        
    func build(with input: WorkoutFinishedScreenBuilderInput) -> WorkoutFinishedScreenModule {
        let interactor = WorkoutFinishedScreenInteractorImpl(dependencies: dependencies, input: input)
        let middleware = WorkoutFinishedScreenMiddlewareImpl(dependencies: dependencies)
        let presenter = WorkoutFinishedScreenPresenterImpl(interactor: interactor, middleware: middleware, initialViewState: WorkoutFinishedScreenViewState(workoutDoneModel: input.workoutDoneModel))
        let view = WorkoutFinishedScreenViewController(presenter: presenter)
        return WorkoutFinishedScreenModule(view: view, callback: middleware)
    }
}
