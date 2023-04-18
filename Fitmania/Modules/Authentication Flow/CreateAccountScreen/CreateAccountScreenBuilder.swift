//
//  CreateAccountScreenBuilder.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 10/04/2023.
//

import UIKit
import RxSwift

final class CreateAccountScreenBuilderImpl: CreateAccountScreenBuilder {
    typealias Dependencies = CreateAccountScreenInteractorImpl.Dependencies & CreateAccountScreenMiddlewareImpl.Dependencies
    private let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
        
    func build(with input: CreateAccountScreenBuilderInput) -> CreateAccountScreenModule {
        let interactor = CreateAccountScreenInteractorImpl(dependencies: dependencies)
        let middleware = CreateAccountScreenMiddlewareImpl(dependencies: dependencies)
        let presenter = CreateAccountScreenPresenterImpl(interactor: interactor, middleware: middleware, initialViewState: CreateAccountScreenViewState())
        let view = CreateAccountScreenViewController(presenter: presenter)
        return CreateAccountScreenModule(view: view, callback: middleware)
    }
}
