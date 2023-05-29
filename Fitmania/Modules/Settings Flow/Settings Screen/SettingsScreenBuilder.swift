//
//  SettingsScreenBuilder.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 29/05/2023.
//

import UIKit
import RxSwift

final class SettingsScreenBuilderImpl: SettingsScreenBuilder {
    typealias Dependencies = SettingsScreenInteractorImpl.Dependencies & SettingsScreenMiddlewareImpl.Dependencies
    private let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
        
    func build(with input: SettingsScreenBuilderInput) -> SettingsScreenModule {
        let interactor = SettingsScreenInteractorImpl(dependencies: dependencies)
        let middleware = SettingsScreenMiddlewareImpl(dependencies: dependencies)
        let presenter = SettingsScreenPresenterImpl(interactor: interactor, middleware: middleware, initialViewState: SettingsScreenViewState())
        let view = SettingsScreenViewController(presenter: presenter)
        return SettingsScreenModule(view: view, callback: middleware)
    }
}
