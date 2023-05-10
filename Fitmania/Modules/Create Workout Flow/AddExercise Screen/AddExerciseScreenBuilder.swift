//
//  AddExerciseScreenBuilder.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 25/04/2023.
//

import UIKit
import RxSwift

final class AddExerciseScreenBuilderImpl: AddExerciseScreenBuilder {
    typealias Dependencies = AddExerciseScreenInteractorImpl.Dependencies & AddExerciseScreenMiddlewareImpl.Dependencies
    private let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
        
    func build(with input: AddExerciseScreenBuilderInput) -> AddExerciseScreenModule {
        let interactor = AddExerciseScreenInteractorImpl(dependencies: dependencies, input: input)
        let middleware = AddExerciseScreenMiddlewareImpl(dependencies: dependencies)
        let presenter = AddExerciseScreenPresenterImpl(interactor: interactor, middleware: middleware, initialViewState: AddExerciseScreenViewState(chosenExercise: input.chosenExercise))
        let view = AddExerciseScreenViewController(presenter: presenter)
        return AddExerciseScreenModule(view: view, callback: middleware)
    }
}
