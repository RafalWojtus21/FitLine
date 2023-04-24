//
//  LoginScreenInteractor.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 07/04/2023.
//

import RxSwift

final class LoginScreenInteractorImpl: LoginScreenInteractor {
    typealias Dependencies = HasAuthManager & HasValidationService
    typealias Result = LoginScreenResult
    
    private let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    func login(email: String, password: String) -> Observable<LoginScreenResult> {
        return dependencies.authManager.login(email: email, password: password)
            .asCompletable()
            .andThen(.just(.effect(.userLoggedIn)))
            .catch({ error -> Observable<LoginScreenResult> in
                guard let authError = error as? AuthError else {
                    return .just(.effect(.somethingWentWrong))
                }
                return .just(.effect(.wrongCredentialsAlert(error: authError.errorDescription)))
            })
    }

    func validateEmail(email: String) -> Observable<LoginScreenResult> {
        dependencies.validationService.validate(.email, input: email)
            .andThen(.just(.partialState(.emailValidationResult(validationMessage: ValidationMessage(message: nil)))))
            .catch { error -> Observable<LoginScreenResult> in
                return .just(.partialState(.emailValidationResult(validationMessage: ValidationMessage(message: error.localizedDescription))))
            }
    }
    
    func validatePassword(password: String) -> Observable<LoginScreenResult> {
        dependencies.validationService.validate(.password, input: password)
            .andThen(.just(.partialState(.passwordValidationResult(validationMessage: ValidationMessage(message: nil)))))
            .catch { error -> Observable<LoginScreenResult> in
                return .just(.partialState(.passwordValidationResult(validationMessage: ValidationMessage(message: error.localizedDescription))))
            }
    }
}
