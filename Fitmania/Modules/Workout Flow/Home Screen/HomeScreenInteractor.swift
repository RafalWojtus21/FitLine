//
//  HomeScreenInteractor.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 19/04/2023.
//

import RxSwift

final class HomeScreenInteractorImpl: HomeScreenInteractor {
    typealias Dependencies = Any
    typealias Result = HomeScreenResult
    
    private let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
}
