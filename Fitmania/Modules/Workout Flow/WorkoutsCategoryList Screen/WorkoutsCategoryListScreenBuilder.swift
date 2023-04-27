//
//  WorkoutsCategoryListScreenBuilder.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 25/04/2023.
//

import UIKit
import RxSwift

final class WorkoutsCategoryListScreenBuilderImpl: WorkoutsCategoryListScreenBuilder {
    typealias Dependencies = WorkoutsCategoryListScreenInteractorImpl.Dependencies & WorkoutsCategoryListScreenMiddlewareImpl.Dependencies
    private let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
        
    func build(with input: WorkoutsCategoryListScreenBuilderInput) -> WorkoutsCategoryListScreenModule {
        let interactor = WorkoutsCategoryListScreenInteractorImpl(dependencies: dependencies)
        let middleware = WorkoutsCategoryListScreenMiddlewareImpl(dependencies: dependencies)
        let presenter = WorkoutsCategoryListScreenPresenterImpl(interactor: interactor, middleware: middleware, initialViewState: WorkoutsCategoryListScreenViewState())
        let view = WorkoutsCategoryListScreenViewController(presenter: presenter)
        return WorkoutsCategoryListScreenModule(view: view, callback: middleware)
    }
}
