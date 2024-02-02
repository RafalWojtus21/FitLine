//
//  SettingsScreenInteractor.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 29/05/2023.
//

import RxSwift

final class SettingsScreenInteractorImpl: SettingsScreenInteractor {
    
    // MARK: Properties
    
    typealias Dependencies = HasAuthManager & HasNotificationService
    typealias Result = SettingsScreenResult
    
    private let dependencies: Dependencies
    
    // MARK: Initialization

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    // MARK: Public Implementation
    
    func signOut() -> RxSwift.Observable<SettingsScreenResult> {
        dependencies.authManager.signOut()
            .andThen(.just(.effect(.showWelcomeScreen)))
            .catch({ error -> Observable<SettingsScreenResult> in
                guard let authError = error as? AuthError else {
                    return .just(.effect(.somethingWentWrong))
                }
                return .just(.effect(.signOutErrorAlert(error: authError.errorDescription)))
            })
    }
    
    func deleteAccount() -> Observable<SettingsScreenResult> {
        dependencies.authManager.deleteAccount()
            .andThen(.just(.effect(.accountDeleted)))
            .catch({ error -> Observable<SettingsScreenResult> in
                guard let authError = error as? AuthError else {
                    return .just(.effect(.somethingWentWrong))
                }
                return .just(.effect(.signOutErrorAlert(error: authError.errorDescription)))
            })
    }
}
