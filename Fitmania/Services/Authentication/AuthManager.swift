//
//  AuthManager.swift
//  FitLine
//
//  Created by Rafał Wojtuś on 06/04/2023.
//

import Foundation
import FirebaseAuth
import RxSwift

protocol HasAuthManager {
    var authManager: AuthManager { get }
}

protocol AuthManager {
    func isLoggedIn() -> Bool
    func getCurrentUser() -> User?
    func signUp(email: String, password: String) -> Single<AuthResponse>
    func login(email: String, password: String) -> Single<AuthResponse>
    func signOut() -> Completable
    func resetPassword(email: String) -> Completable
}

protocol Authentication {
    func addStateDidChangeListener(_ listener: @escaping (Auth, User?) -> Void) -> AuthStateDidChangeListenerHandle
    var currentUser: User? { get }
    func createUser(withEmail: String, password: String, completion: ((AuthDataResult?, Error?) -> Void)?)
    func signIn(withEmail email: String, password: String, completion: ((AuthDataResult?, Error?) -> Void)?)
    func signOut() throws
    func sendPasswordReset(withEmail email: String, completion: ((Error?) -> Void)?)
}

extension Auth: Authentication {}

final class AuthManagerImpl: AuthManager {
    
    // MARK: Properties

    private let auth: Authentication
    
    // MARK: Initialization

    init(auth: Authentication) {
        self.auth = auth
    }
    
    // MARK: Public Implementation
    
    func isLoggedIn() -> Bool {
        if getCurrentUser() != nil {
            return true
        } else {
            return false
        }
    }

    func getCurrentUser() -> User? {
        auth.currentUser
    }
    
    func signUp(email: String, password: String) -> Single<AuthResponse> {
        return Single.create { single in
            self.auth.createUser(withEmail: email, password: password) { authResult, error in
                if let error = error as NSError? {
                    switch error.code {
                    case AuthErrorCode.invalidEmail.rawValue:
                        single(.failure(AuthError.invalidEmail))
                    case AuthErrorCode.weakPassword.rawValue:
                        single(.failure(AuthError.weakPassword))
                    case AuthErrorCode.emailAlreadyInUse.rawValue:
                        single(.failure(AuthError.emailAlreadyInUse))
                    default:
                        single(.failure(AuthError.signUpError))
                    }
                } else if let authResult = authResult {
                    // swiftlint:disable:next force_unwrapping
                    single(.success(AuthResponse(email: authResult.user.email!, uid: authResult.user.uid)))
                } else {
                    single(.failure(AuthError.signUpError))
                }
            }
            return Disposables.create()
        }
    }
    
    func login(email: String, password: String) -> Single<AuthResponse> {
        return Single.create { single in
            self.auth.signIn(withEmail: email, password: password) { authResult, error in
                if let error = error as NSError? {
                    switch error.code {
                    case AuthErrorCode.invalidEmail.rawValue:
                        single(.failure(AuthError.invalidEmail))
                    case AuthErrorCode.wrongPassword.rawValue:
                        single(.failure(AuthError.wrongPassword))
                    case AuthErrorCode.userNotFound.rawValue:
                        single(.failure(AuthError.userNotFound))
                    default:
                        single(.failure(AuthError.loginError))
                    }
                } else if let authResult = authResult {
                    // swiftlint:disable:next force_unwrapping
                    single(.success(AuthResponse(email: authResult.user.email!, uid: authResult.user.uid)))
                } else {
                    single(.failure(AuthError.loginError))
                }
            }
            return Disposables.create()
        }
    }
    
    func signOut() -> Completable {
        return Completable.create { completable in
            do {
                try self.auth.signOut()
                completable(.completed)
            } catch {
                completable(.error(error))
            }
            return Disposables.create()
        }
    }
    
    func resetPassword(email: String) -> Completable {
        return Completable.create { completable in
            self.auth.sendPasswordReset(withEmail: email) { error in
                guard let error else { return completable(.completed) }
                completable(.error(error))
            }
            return Disposables.create()
        }
    }
}
