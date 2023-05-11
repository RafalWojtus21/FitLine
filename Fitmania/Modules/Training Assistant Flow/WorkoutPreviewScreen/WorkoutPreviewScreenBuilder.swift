//
//  WorkoutPreviewScreenBuilder.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 10/05/2023.
//

import UIKit
import RxSwift

final class WorkoutPreviewScreenBuilderImpl: WorkoutPreviewScreenBuilder {
    typealias Dependencies = WorkoutPreviewScreenInteractorImpl.Dependencies & WorkoutPreviewScreenMiddlewareImpl.Dependencies
    private let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
        
    func build(with input: WorkoutPreviewScreenBuilderInput) -> WorkoutPreviewScreenModule {
        let interactor = WorkoutPreviewScreenInteractorImpl(dependencies: dependencies)
        let middleware = WorkoutPreviewScreenMiddlewareImpl(dependencies: dependencies)
        let presenter = WorkoutPreviewScreenPresenterImpl(interactor: interactor, middleware: middleware, initialViewState: WorkoutPreviewScreenViewState(chosenWorkout: input.chosenWorkout))
        let view = WorkoutPreviewScreenViewController(presenter: presenter)
        return WorkoutPreviewScreenModule(view: view, callback: middleware)
    }
}
