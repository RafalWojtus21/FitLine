//
//  ForgotPasswordScreenInteractor.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 09/04/2023.
//

import RxSwift

final class ForgotPasswordScreenInteractorImpl: ForgotPasswordScreenInteractor {
    typealias Dependencies = HasAuthManager & HasValidationService
    typealias Result = ForgotPasswordScreenResult
    
    private let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    func resetPassword(email: String) -> Observable<ForgotPasswordScreenResult> {
        dependencies.authManager.resetPassword(email: email)
            .andThen(.just(.effect(.emailSent)))
            .catch({ error -> Observable<ForgotPasswordScreenResult> in
                guard let authError = error as? AuthError else {
                    return .just(.effect(.somethingWentWrong))
                }
                return .just(.effect(.passwordResetError(error: authError.errorDescription)))
            })
    }
    
    func validateEmail(email: String) -> Observable<ForgotPasswordScreenResult> {
        dependencies.validationService.validate(.email, input: email)
            .andThen(.just(.partialState(.emailValidationResult(validationMessage: ValidationMessage(message: nil)))))
            .catch { error -> Observable<ForgotPasswordScreenResult> in
                return .just(.partialState(.emailValidationResult(validationMessage: ValidationMessage(message: error.localizedDescription))))
            }
    }
}
