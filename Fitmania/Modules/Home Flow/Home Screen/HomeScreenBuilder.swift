//
//  HomeScreenBuilder.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 19/04/2023.
//

import UIKit
import RxSwift

final class HomeScreenBuilderImpl: HomeScreenBuilder {
    typealias Dependencies = HomeScreenInteractorImpl.Dependencies & HomeScreenMiddlewareImpl.Dependencies
    private let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
        
    func build(with input: HomeScreenBuilderInput) -> HomeScreenModule {
        let interactor = HomeScreenInteractorImpl(dependencies: dependencies)
        let middleware = HomeScreenMiddlewareImpl(dependencies: dependencies)
        let presenter = HomeScreenPresenterImpl(interactor: interactor, middleware: middleware, initialViewState: HomeScreenViewState())
        let view = HomeScreenViewController(presenter: presenter)
        return HomeScreenModule(view: view, callback: middleware)
    }
}
