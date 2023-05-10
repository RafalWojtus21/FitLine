//
//  CategoryExercisesListBuilder.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 25/04/2023.
//

import UIKit
import RxSwift

final class CategoryExercisesListBuilderImpl: CategoryExercisesListBuilder {
    typealias Dependencies = CategoryExercisesListInteractorImpl.Dependencies & CategoryExercisesListMiddlewareImpl.Dependencies
    private let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
        
    func build(with input: CategoryExercisesListBuilderInput) -> CategoryExercisesListModule {
        let interactor = CategoryExercisesListInteractorImpl(dependencies: dependencies, input: input)
        let middleware = CategoryExercisesListMiddlewareImpl(dependencies: dependencies)
        let presenter = CategoryExercisesListPresenterImpl(interactor: interactor, middleware: middleware, initialViewState: CategoryExercisesListViewState(chosenCategory: input.chosenCategory))
        let view = CategoryExercisesListViewController(presenter: presenter)
        return CategoryExercisesListModule(view: view, callback: middleware)
    }
}
