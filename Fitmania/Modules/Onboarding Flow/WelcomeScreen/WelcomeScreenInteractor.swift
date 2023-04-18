//
//  WelcomeScreenInteractor.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 05/04/2023.
//

import RxSwift

final class WelcomeScreenInteractorImpl: WelcomeScreenInteractor {
    typealias Dependencies = Any
    typealias Result = WelcomeScreenResult
    
    private let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
}
