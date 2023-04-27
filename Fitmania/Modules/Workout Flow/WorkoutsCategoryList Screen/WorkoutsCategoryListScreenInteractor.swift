//
//  WorkoutsCategoryListScreenInteractor.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 25/04/2023.
//

import RxSwift

final class WorkoutsCategoryListScreenInteractorImpl: WorkoutsCategoryListScreenInteractor {
    typealias Dependencies = Any
    typealias Result = WorkoutsCategoryListScreenResult
    
    private let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
}
