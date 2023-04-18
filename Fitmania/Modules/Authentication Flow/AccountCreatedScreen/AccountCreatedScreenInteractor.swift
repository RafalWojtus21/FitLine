//
//  AccountCreatedScreenInteractor.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 18/04/2023.
//

import RxSwift

final class AccountCreatedScreenInteractorImpl: AccountCreatedScreenInteractor {
    typealias Dependencies = Any
    typealias Result = AccountCreatedScreenResult
    
    private let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
}
