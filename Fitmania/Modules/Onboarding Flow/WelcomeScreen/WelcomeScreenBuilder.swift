//
//  WelcomeScreenBuilder.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 05/04/2023.
//

import UIKit
import RxSwift

final class WelcomeScreenBuilderImpl: WelcomeScreenBuilder {
    typealias Dependencies = WelcomeScreenInteractorImpl.Dependencies & WelcomeScreenMiddlewareImpl.Dependencies
    private let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
        
    func build(with input: WelcomeScreenBuilderInput) -> WelcomeScreenModule {
        let interactor = WelcomeScreenInteractorImpl(dependencies: dependencies)
        let middleware = WelcomeScreenMiddlewareImpl(dependencies: dependencies)
        let presenter = WelcomeScreenPresenterImpl(interactor: interactor, middleware: middleware, initialViewState: WelcomeScreenViewState())
        let view = WelcomeScreenViewController(presenter: presenter)
        return WelcomeScreenModule(view: view, callback: middleware)
    }
}
