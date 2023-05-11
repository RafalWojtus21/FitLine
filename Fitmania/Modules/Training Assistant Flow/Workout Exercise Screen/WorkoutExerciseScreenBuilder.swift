//
//  WorkoutExerciseScreenBuilder.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 11/05/2023.
//

import UIKit
import RxSwift

final class WorkoutExerciseScreenBuilderImpl: WorkoutExerciseScreenBuilder {
    typealias Dependencies = WorkoutExerciseScreenInteractorImpl.Dependencies & WorkoutExerciseScreenMiddlewareImpl.Dependencies
    private let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    func build(with input: WorkoutExerciseScreenBuilderInput) -> WorkoutExerciseScreenModule {
        let interactor = WorkoutExerciseScreenInteractorImpl(dependencies: dependencies, workoutPlan: input.chosenPlan)
        let middleware = WorkoutExerciseScreenMiddlewareImpl(dependencies: dependencies)
        let presenter = WorkoutExerciseScreenPresenterImpl(interactor: interactor, middleware: middleware, initialViewState: WorkoutExerciseScreenViewState(chosenPlan: input.chosenPlan, timeLeft: input.chosenPlan.parts.first?.time ?? 0))
        let view = WorkoutExerciseScreenViewController(presenter: presenter)
        return WorkoutExerciseScreenModule(view: view, callback: middleware)
    }
}
