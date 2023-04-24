//
//  Error.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 07/04/2023.
//

import Foundation

enum AuthError: LocalizedError, Equatable {
    typealias L = Localization.AuthErrors
    case signUpError
    case loginError
    case userNotLoggedIn
    case invalidEmail
    case weakPassword
    case emailAlreadyInUse
    case wrongPassword
    case invalidCredential
    
    var errorDescription: String {
        switch self {
        case .signUpError:
            return L.signUpError
        case .loginError:
            return L.loginError
        case .userNotLoggedIn:
            return L.userNotLoggedIn
        case .invalidEmail:
            return L.invalidEmail
        case .weakPassword:
            return L.weakPassword
        case .emailAlreadyInUse:
            return L.emailAlreadyInUse
        case .wrongPassword:
            return L.wrongPassword
        case .invalidCredential:
            return L.invalidCredential
        }
    }
}

enum FirestoreError: Error, Equatable {
    case noData
    case somethingWentWrong
}
