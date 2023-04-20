//
//  AuthMock.swift
//  FitmaniaTests
//
//  Created by Rafał Wojtuś on 05/05/2023.
//

import Foundation
@testable import Fitmania
import FirebaseAuth

class AuthStateDidChangeListenerHandleMock: NSObject {
}

class AuthMock: Authentication {
    var stateDidChangeBlock: ((Auth, User?) -> Void)? = nil
    func addStateDidChangeListener(_ listener: @escaping (Auth, User?) -> Void) -> AuthStateDidChangeListenerHandle {
        stateDidChangeBlock = listener
        return AuthStateDidChangeListenerHandleMock()
    }
    
    var currentUser: User?
    
    var createUserResult: AuthDataResult?
    var createUserError: Error?
    func createUser(withEmail: String, password: String, completion: ((AuthDataResult?, Error?) -> Void)?) {
        completion?(createUserResult, createUserError)
    }
    
    var signInResult: AuthDataResult?
    var signInError: Error?
    func signIn(withEmail email: String, password: String, completion: ((AuthDataResult?, Error?) -> Void)?) {
        completion?(signInResult, signInError)
    }
    
    var signOutError: Error?
    func signOut() throws {
        if let signOutError {
            throw signOutError
        }
    }
    
    var passwordResetError: Error?
    func sendPasswordReset(withEmail email: String, completion: ((Error?) -> Void)?) {
        completion?(passwordResetError)
    }
}
