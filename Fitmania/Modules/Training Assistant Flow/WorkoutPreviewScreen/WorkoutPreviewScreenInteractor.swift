//
//  WorkoutPreviewScreenInteractor.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 10/05/2023.
//

import RxSwift

final class WorkoutPreviewScreenInteractorImpl: WorkoutPreviewScreenInteractor {
    typealias Dependencies = Any
    typealias Result = WorkoutPreviewScreenResult
    
    private let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
}
