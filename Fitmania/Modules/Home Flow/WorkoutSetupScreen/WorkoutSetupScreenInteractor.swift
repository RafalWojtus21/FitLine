//
//  WorkoutSetupScreenInteractor.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 25/04/2023.
//

import RxSwift

final class WorkoutSetupScreenInteractorImpl: WorkoutSetupScreenInteractor {
    typealias Dependencies = Any
    typealias Result = WorkoutSetupScreenResult
    
    private let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
}
