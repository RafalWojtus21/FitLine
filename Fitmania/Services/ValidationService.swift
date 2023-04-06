//
//  ValidationService2.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 13/04/2023.
//

import Foundation
import RxSwift

enum Validation {
    typealias L = Localization.Validation
    enum ValidationType: String {
        case email = "e-mail"
        case password = "password"
        case username = "name"
        
        enum RegexPatterns: String {
            case email = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            case passwordUppercase = ".*[A-Z].*"
            case passwordLowercase = ".*[a-z].*"
            case passwordDigit = ".*[0-9].*"
            case passwordCharacter = ".*[^a-zA-Z0-9].*"
            case passwordLength = ".{8,256}"
        }

        var predicates: [(NSPredicate, String)] {
             switch self {
             case .email:
                 return [(NSPredicate.matchPredicate(regex: .email), L.invalidEmailError)]
             case .password:
                 return [
                    (NSPredicate.matchPredicate(regex: .passwordUppercase), L.passwordUppercaseError),
                    (NSPredicate.matchPredicate(regex: .passwordLowercase), L.passwordLowerCaseError),
                    (NSPredicate.matchPredicate(regex: .passwordDigit), L.passwordDigitError),
                    (NSPredicate.matchPredicate(regex: .passwordCharacter), L.passwordCharacterError),
                    (NSPredicate.matchPredicate(regex: .passwordLength), L.passwordLengthError)
                 ]
             default:
                 return []
             }
         }
    }
    
    enum ValidationResult {
        case empty(message: String)
        case valid
        case invalid(message: String)
    }

    struct Error: LocalizedError {
        let errorDescription: String?
    }
}

protocol HasValidationService {
    var validationService: ValidationService { get }
}

protocol ValidationService {
    func validate(_ type: Validation.ValidationType, input: String) -> Completable
}

final class ValidationServiceImpl: ValidationService {
    typealias L = Localization.Validation

    func validate(_ type: Validation.ValidationType, input: String) -> Completable {
        Completable.create { completable in
            if input.isEmpty {
                completable(.error(Validation.Error(errorDescription: L.emptyFieldError + " " + type.rawValue)))
            }
            for (predicate, errorMessage) in type.predicates where !predicate.evaluate(with: input) {
                completable(.error(Validation.Error(errorDescription: errorMessage)))
            }
            completable(.completed)
            return Disposables.create()
        }
    }
}
