//
//  ForgotPasswordScreenBuilder.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 09/04/2023.
//

import UIKit
import RxSwift

final class ForgotPasswordScreenBuilderImpl: ForgotPasswordScreenBuilder {
    typealias Dependencies = ForgotPasswordScreenInteractorImpl.Dependencies & ForgotPasswordScreenMiddlewareImpl.Dependencies
    private let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
        
    func build(with input: ForgotPasswordScreenBuilderInput) -> ForgotPasswordScreenModule {
        let interactor = ForgotPasswordScreenInteractorImpl(dependencies: dependencies)
        let middleware = ForgotPasswordScreenMiddlewareImpl(dependencies: dependencies)
        let presenter = ForgotPasswordScreenPresenterImpl(interactor: interactor, middleware: middleware, initialViewState: ForgotPasswordScreenViewState())
        let view = ForgotPasswordScreenViewController(presenter: presenter)
        return ForgotPasswordScreenModule(view: view, callback: middleware)
    }
}
