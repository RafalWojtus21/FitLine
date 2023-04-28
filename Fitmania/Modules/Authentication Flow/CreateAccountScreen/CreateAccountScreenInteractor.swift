//
//  CreateAccountScreenInteractor.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 10/04/2023.
//

import RxSwift

final class CreateAccountScreenInteractorImpl: CreateAccountScreenInteractor {
    typealias Dependencies = HasCloudService & HasValidationService
    typealias Result = CreateAccountScreenResult
    
    private let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    func saveUserInfo(userInfo: UserInfo) -> Observable<CreateAccountScreenResult> {
        return dependencies.cloudService.savePersonalData(data: userInfo, endpoint: .userInfo, encoder: nil)
            .andThen(Observable.just(.effect(.showAccountCreatedScreen)))
            .catch { error -> Observable<CreateAccountScreenResult> in
                return .just(.effect(.somethingWentWrong(error: error.localizedDescription)))
            }
    }
    
    func validateName(name: String) -> Observable<CreateAccountScreenResult> {
        dependencies.validationService.validate(.username, input: name)
            .andThen(.just(.partialState(.firstNameValidationResult(validationMessage: ValidationMessage(message: nil)))))
            .catch { error -> Observable<CreateAccountScreenResult> in
                return .just(.partialState(.firstNameValidationResult(validationMessage: ValidationMessage(message: error.localizedDescription))))
            }
    }
    
    func validateLastName(lastName: String) -> Observable<CreateAccountScreenResult> {
        dependencies.validationService.validate(.username, input: lastName)
            .andThen(.just(.partialState(.lastNameValidationResult(validationMessage: ValidationMessage(message: nil)))))
            .catch { error -> Observable<CreateAccountScreenResult> in
                return .just(.partialState(.lastNameValidationResult(validationMessage: ValidationMessage(message: error.localizedDescription))))
            }
    }
    
    func validateSex(sex: String) -> Observable<CreateAccountScreenResult> {
        dependencies.validationService.validate(.sex, input: sex)
            .andThen(.just(.partialState(.sexValidationResult(validationMessage: ValidationMessage(message: nil)))))
            .catch { error -> Observable<CreateAccountScreenResult> in
                return .just(.partialState(.sexValidationResult(validationMessage: ValidationMessage(message: error.localizedDescription))))
            }
    }
    
    func validateAge(age: String) -> Observable<CreateAccountScreenResult> {
        dependencies.validationService.validate(.age, input: age)
            .andThen(.just(.partialState(.ageValidationResult(validationMessage: ValidationMessage(message: nil)))))
            .catch { error -> Observable<CreateAccountScreenResult> in
                return .just(.partialState(.ageValidationResult(validationMessage: ValidationMessage(message: error.localizedDescription))))
            }
    }
    
    func validateHeight(height: String) -> Observable<CreateAccountScreenResult> {
        dependencies.validationService.validate(.height, input: height)
            .andThen(.just(.partialState(.heightValidationResult(validationMessage: ValidationMessage(message: nil)))))
            .catch { error -> Observable<CreateAccountScreenResult> in
                return .just(.partialState(.heightValidationResult(validationMessage: ValidationMessage(message: error.localizedDescription))))
            }
    }
    
    func validateWeight(weight: String) -> Observable<CreateAccountScreenResult> {
        dependencies.validationService.validate(.weight, input: weight)
            .andThen(.just(.partialState(.weightValidationResult(validationMessage: ValidationMessage(message: nil)))))
            .catch { error -> Observable<CreateAccountScreenResult> in
                return .just(.partialState(.weightValidationResult(validationMessage: ValidationMessage(message: error.localizedDescription))))
            }
    }
}
