//
//  EditPersonalDataScreenBuilder.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 12/01/2024.
//

import UIKit
import RxSwift

final class EditPersonalDataScreenBuilderImpl: EditPersonalDataScreenBuilder {
    typealias Dependencies = EditPersonalDataScreenInteractorImpl.Dependencies & EditPersonalDataScreenMiddlewareImpl.Dependencies
    private let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
        
    func build(with input: EditPersonalDataScreenBuilderInput) -> EditPersonalDataScreenModule {
        let interactor = EditPersonalDataScreenInteractorImpl(dependencies: dependencies)
        let middleware = EditPersonalDataScreenMiddlewareImpl(dependencies: dependencies)
        let presenter = EditPersonalDataScreenPresenterImpl(interactor: interactor, middleware: middleware, initialViewState: EditPersonalDataScreenViewState())
        let view = EditPersonalDataScreenViewController(presenter: presenter)
        return EditPersonalDataScreenModule(view: view, callback: middleware)
    }
}
