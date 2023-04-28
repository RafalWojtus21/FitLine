//
//  AuthManagerMock.swift
//  FitmaniaTests
//
//  Created by Rafał Wojtuś on 20/04/2023.
//

import Foundation
import RxSwift
import FirebaseAuth

@testable import Fitmania

final class AuthManagerMock: AuthManager {
    var currentUser: User?
    func getCurrentUser() -> User? {
        currentUser
    }
    
    func isLoggedIn() -> Bool {
        if currentUser != nil {
            return true
        } else {
            return false
        }
    }

    var signUpAuthResult: Single<AuthResponse> = .just(.init(email: "testEmail@untitledkingdom.com", uid: "uuid12345"))
    func signUp(email: String, password: String) -> Single<AuthResponse> {
        signUpAuthResult
    }
    
    var loginAuthResult: Single<AuthResponse> = .just(.init(email: "testEmail@untitledkingdom.com", uid: "uuid12345"))
    func login(email: String, password: String) -> Single<AuthResponse> {
        loginAuthResult
    }
    
    var signOutResponse: CompletableEvent = .completed
    func signOut() -> Completable {
        signOutResponse.asCompletable()
    }
    
    var resetResponse: CompletableEvent = .completed
    func resetPassword(email: String) -> Completable {
        resetResponse.asCompletable()
    }
}
