//
//  ScheduleWorkoutScreenBuilder.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 10/05/2023.
//

import UIKit
import RxSwift

final class ScheduleWorkoutScreenBuilderImpl: ScheduleWorkoutScreenBuilder {
    typealias Dependencies = ScheduleWorkoutScreenInteractorImpl.Dependencies & ScheduleWorkoutScreenMiddlewareImpl.Dependencies
    private let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
        
    func build(with input: ScheduleWorkoutScreenBuilderInput) -> ScheduleWorkoutScreenModule {
        let interactor = ScheduleWorkoutScreenInteractorImpl(dependencies: dependencies, chosenWorkout: input.chosenWorkout)
        let middleware = ScheduleWorkoutScreenMiddlewareImpl(dependencies: dependencies)
        let presenter = ScheduleWorkoutScreenPresenterImpl(interactor: interactor, middleware: middleware, initialViewState: ScheduleWorkoutScreenViewState(chosenWorkout: input.chosenWorkout))
        let view = ScheduleWorkoutScreenViewController(presenter: presenter)
        return ScheduleWorkoutScreenModule(view: view, callback: middleware)
    }
}
