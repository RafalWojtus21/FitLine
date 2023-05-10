//
//  WorkoutsListScreenBuilder.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 20/04/2023.
//

import UIKit
import RxSwift

final class WorkoutsListScreenBuilderImpl: WorkoutsListScreenBuilder {
    typealias Dependencies = WorkoutsListScreenInteractorImpl.Dependencies & WorkoutsListScreenMiddlewareImpl.Dependencies
    private let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
        
    func build(with input: WorkoutsListScreenBuilderInput) -> WorkoutsListScreenModule {
        let interactor = WorkoutsListScreenInteractorImpl(dependencies: dependencies)
        let middleware = WorkoutsListScreenMiddlewareImpl(dependencies: dependencies)
        let presenter = WorkoutsListScreenPresenterImpl(interactor: interactor, middleware: middleware, initialViewState: WorkoutsListScreenViewState())
        let view = WorkoutsListScreenViewController(presenter: presenter)
        return WorkoutsListScreenModule(view: view, callback: middleware)
    }
}
