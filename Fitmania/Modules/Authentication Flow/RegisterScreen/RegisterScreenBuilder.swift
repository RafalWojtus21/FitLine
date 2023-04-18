//
//  RegisterScreenBuilder.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 06/04/2023.
//

import UIKit
import RxSwift

final class RegisterScreenBuilderImpl: RegisterScreenBuilder {
    typealias Dependencies = RegisterScreenInteractorImpl.Dependencies & RegisterScreenMiddlewareImpl.Dependencies
    private let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
        
    func build(with input: RegisterScreenBuilderInput) -> RegisterScreenModule {
        let interactor = RegisterScreenInteractorImpl(dependencies: dependencies)
        let middleware = RegisterScreenMiddlewareImpl(dependencies: dependencies)
        let presenter = RegisterScreenPresenterImpl(interactor: interactor, middleware: middleware, initialViewState: RegisterScreenViewState())
        let view = RegisterScreenViewController(presenter: presenter)
        return RegisterScreenModule(view: view, callback: middleware)
    }
}
