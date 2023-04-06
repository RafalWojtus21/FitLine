//
//  LocalizationValidation.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 13/04/2023.
//

import Foundation
extension Localization {
    enum Validation {
        static let emailValidationType = "Validation.Email".localized
        static let passwordValidationType = "Validation.Password".localized
        static let userNameValidationType = "Validation.Username".localized
        static let emptyFieldError = "Validation.EmptyField".localized
        static let invalidFieldError = "Validation.InvalidFieldInput".localized
        static let invalidEmailError = "Validation.InvalidEmailError".localized
        static let repeatPasswordError = "Validation.RepeatPasswordError".localized
        static let passwordUppercaseError = "Validation.PasswordUppercaseError".localized
        static let passwordLowerCaseError = "Validation.PasswordLowercaseError".localized
        static let passwordDigitError = "Validation.PasswordDigitError".localized
        static let passwordCharacterError = "Validation.PasswordCharacterError".localized
        static let passwordLengthError = "Validation.PasswordLengthError".localized
    }
}
