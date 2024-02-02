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
        case sex
        case age
        case height
        case weight
        case workoutTime
        case workoutSets
        
        enum RegexPatterns: String {
            case email = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            case passwordUppercase = ".*[A-Z].*"
            case passwordLowercase = ".*[a-z].*"
            case passwordDigit = ".*[0-9].*"
            case passwordCharacter = ".*[^a-zA-Z0-9].*"
            case passwordLength = ".{8,256}"
            case name = "^[a-zA-ZąćęłńóśźżĄĆĘŁŃÓŚŹŻ]{3,40}$"
            case age = "^(1[0-2][0-9]|[1-9][0-9]|[1-9])$"
            case height = "^(2[0-2][0-9]|23[0-9]|[1][0-9][0-9]|[2-9][0-9]|[2-9])$"
            case weight = "^(2[3-4][0-9]|25[0-9]|[3-9][0-9]|[1-2][0-4][0-9]|250|[3-9][0-9]|[1-2][0-9]|30)$"
            case workoutTime = "^(?!0\\d)\\d{1,4}$|^(10[0-7]\\d{2}|10800)$"
            case workoutSets = "^(1?[0-9]|20)$"
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
             case .username:
                 return [
                    (NSPredicate.matchPredicate(regex: .name), L.invalidNameError)
                 ]
             case .age:
                 return [
                    (NSPredicate.matchPredicate(regex: .age), L.invalidAgeError)
                 ]
             case .height:
                 return [
                    (NSPredicate.matchPredicate(regex: .height), L.invalidHeightError)
                 ]
             case .weight:
                 return [
                    (NSPredicate.matchPredicate(regex: .weight), L.invalidWeightError)
                 ]
             case .workoutTime:
                 return [
                    (NSPredicate.matchPredicate(regex: .workoutTime), L.invalidWorkoutTimeError)
                 ]
             case .workoutSets:
                 return [
                    (NSPredicate.matchPredicate(regex: .workoutSets), L.invalidSetsNumberError)
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

    struct Error: LocalizedError, Equatable {
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
                completable(.error(Validation.Error(errorDescription: Localization.Validation.emptyFieldError + " " + type.rawValue)))
            }
            for (predicate, errorMessage) in type.predicates where !predicate.evaluate(with: input) {
                completable(.error(Validation.Error(errorDescription: errorMessage)))
            }
            completable(.completed)
            return Disposables.create()
        }
    }
}
