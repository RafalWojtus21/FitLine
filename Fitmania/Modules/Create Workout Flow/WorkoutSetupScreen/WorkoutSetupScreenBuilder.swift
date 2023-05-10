//
//  WorkoutSetupScreenBuilder.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 25/04/2023.
//

import UIKit
import RxSwift

final class WorkoutSetupScreenBuilderImpl: WorkoutSetupScreenBuilder {
    typealias Dependencies = WorkoutSetupScreenInteractorImpl.Dependencies & WorkoutSetupScreenMiddlewareImpl.Dependencies
    private let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
        
    func build(with input: WorkoutSetupScreenBuilderInput) -> WorkoutSetupScreenModule {
        let interactor = WorkoutSetupScreenInteractorImpl(dependencies: dependencies, input: input)
        let middleware = WorkoutSetupScreenMiddlewareImpl(dependencies: dependencies)
        let presenter = WorkoutSetupScreenPresenterImpl(interactor: interactor, middleware: middleware, initialViewState: WorkoutSetupScreenViewState(trainingName: input.trainingName))
        let view = WorkoutSetupScreenViewController(presenter: presenter)
        return WorkoutSetupScreenModule(view: view, callback: middleware)
    }
}
