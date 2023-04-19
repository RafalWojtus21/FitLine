//
//  AuthManager.swift
//  Fitmania
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
    func isLoggedIn(completion: @escaping (Bool) -> Void)
    func getCurrentUser() -> User?
    func signUp(email: String, password: String) -> Single<AuthDataResult>
    func login(email: String, password: String) -> Single<AuthDataResult>
    func signOut() -> Completable
    func resetPassword(email: String) -> Completable
}

final class AuthManagerImpl: AuthManager {
    private let auth = Auth.auth()
    
    func isLoggedIn(completion: @escaping (Bool) -> Void) {
        auth.addStateDidChangeListener { _, user in
            if user != nil {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func getCurrentUser() -> User? {
        self.auth.currentUser
    }
    
    func signUp(email: String, password: String) -> Single<AuthDataResult> {
        return Single.create { single in
            self.auth.createUser(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    single(.failure(error))
                } else if let authResult = authResult {
                    single(.success(authResult))
                } else {
                    single(.failure(AuthError.signUpError))
                }
            }
            return Disposables.create()
        }
    }
    
    func login(email: String, password: String) -> Single<AuthDataResult> {
        return Single.create { single in
            self.auth.signIn(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    single(.failure(error))
                } else if let authResult = authResult {
                    single(.success(authResult))
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
