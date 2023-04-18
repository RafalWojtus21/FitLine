//
//  AccountCreatedScreenBuilder.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 18/04/2023.
//

import UIKit
import RxSwift

final class AccountCreatedScreenBuilderImpl: AccountCreatedScreenBuilder {
    typealias Dependencies = AccountCreatedScreenInteractorImpl.Dependencies & AccountCreatedScreenMiddlewareImpl.Dependencies
    private let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
        
    func build(with input: AccountCreatedScreenBuilderInput) -> AccountCreatedScreenModule {
        let interactor = AccountCreatedScreenInteractorImpl(dependencies: dependencies)
        let middleware = AccountCreatedScreenMiddlewareImpl(dependencies: dependencies)
        let presenter = AccountCreatedScreenPresenterImpl(interactor: interactor, middleware: middleware, initialViewState: AccountCreatedScreenViewState())
        let view = AccountCreatedScreenViewController(presenter: presenter)
        return AccountCreatedScreenModule(view: view, callback: middleware)
    }
}
