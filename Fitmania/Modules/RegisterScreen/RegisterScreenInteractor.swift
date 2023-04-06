//
//  RegisterScreenInteractor.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 06/04/2023.
//

import RxSwift

final class RegisterScreenInteractorImpl: RegisterScreenInteractor {
    typealias Dependencies = HasAuthManager & HasValidationService
    typealias Result = RegisterScreenResult
    
    private let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    func validateEmail(email: String) -> Observable<RegisterScreenResult> {
        dependencies.validationService.validate(.email, input: email)
            .andThen(.just(.partialState(.emailValidationResult(validationMessage: ValidationMessage(message: nil)))))
            .catch { error -> Observable<RegisterScreenResult> in
                return .just(.partialState(.emailValidationResult(validationMessage: ValidationMessage(message: error.localizedDescription))))
            }
    }

    func validatePassword(password: String) -> Observable<RegisterScreenResult> {
        dependencies.validationService.validate(.password, input: password)
            .andThen(.just(.partialState(.passwordValidationResult(validationMessage: ValidationMessage(message: nil)))))
            .catch { error -> Observable<RegisterScreenResult> in
                return .just(.partialState(.passwordValidationResult(validationMessage: ValidationMessage(message: error.localizedDescription))))
            }
    }
    
    func validateRepeatPassword(password: String, repeatPassword: String) -> Observable<RegisterScreenResult> {
        if password == repeatPassword {
            return .just(.partialState(.repeatPasswordValidationResult(validationMessage: ValidationMessage(message: nil))))
        } else {
            return .just(.partialState(.repeatPasswordValidationResult(validationMessage: ValidationMessage(message: Localization.Validation.repeatPasswordError))))
        }
    }
    
    func register(email: String, password: String) -> Observable<RegisterScreenResult> {
        return dependencies.authManager.signUp(email: email, password: password)
            .asCompletable()
            .andThen(.just(.effect(.showAccountSetupScreen)))
            .catch({ error -> Observable<RegisterScreenResult> in
                return .just(.effect(.registerError(error: error.localizedDescription)))
            })
    }
}
