//
//  LoginScreenBuilder.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 07/04/2023.
//

import UIKit
import RxSwift

final class LoginScreenBuilderImpl: LoginScreenBuilder {
    typealias Dependencies = LoginScreenInteractorImpl.Dependencies & LoginScreenMiddlewareImpl.Dependencies
    private let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
        
    func build(with input: LoginScreenBuilderInput) -> LoginScreenModule {
        let interactor = LoginScreenInteractorImpl(dependencies: dependencies)
        let middleware = LoginScreenMiddlewareImpl(dependencies: dependencies)
        let presenter = LoginScreenPresenterImpl(interactor: interactor, middleware: middleware, initialViewState: LoginScreenViewState())
        let view = LoginScreenViewController(presenter: presenter)
        return LoginScreenModule(view: view, callback: middleware)
    }
}
