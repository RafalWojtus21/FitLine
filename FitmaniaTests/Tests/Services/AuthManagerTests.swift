//
//  AuthManagerTests.swift
//  FitmaniaTests
//
//  Created by Rafał Wojtuś on 21/04/2023.
//

@testable import Fitmania
import XCTest
import RxSwift
import RxTest
import RxBlocking
import FirebaseAuth

final class AuthManagerTests: XCTestCase {
    var sut: AuthManager!
    var authMock: AuthMock!
    
    override func setUp() {
        authMock = AuthMock()
        sut = AuthManagerImpl(auth: authMock)
    }
    
    func testSignUpInvalidEmail() {
        let email = "example@example"
        let password = "12341421"
        authMock.createUserError = NSError(domain: AuthErrorDomain, code: AuthErrorCode.invalidEmail.rawValue)
        let result = try! sut.signUp(email: email, password: password)
            .toArrayAndBlocking()
        let expected: [Event<AuthResponse>] = [.error(AuthError.invalidEmail)]
        XCTAssertEqual(result, expected)
    }
    
    func testSignUpWeakPassword() {
        let email = "example@example123.com"
        let password = "1"
        authMock.createUserError = NSError(domain: AuthErrorDomain, code: AuthErrorCode.weakPassword.rawValue)
        let result = try! sut.signUp(email: email, password: password)
            .toArrayAndBlocking()
        let expected: [Event<AuthResponse>] = [.error(AuthError.weakPassword)]
        XCTAssertEqual(result, expected)
    }
    
    func testSignUpEmailAlreadyInUse() {
        let email = "testEmail@uk.com"
        let password = "12341421"
        authMock.createUserError = NSError(domain: AuthErrorDomain, code: AuthErrorCode.emailAlreadyInUse.rawValue)
        let result = try! sut.signUp(email: email, password: password)
            .toArrayAndBlocking()
        let expected: [Event<AuthResponse>] = [.error(AuthError.emailAlreadyInUse)]
        XCTAssertEqual(result, expected)
    }

    func testLoginUserNotFound() {
        let email = "example@example.pl"
        let password = "pass"
        authMock.signInError = NSError(domain: AuthErrorDomain, code: AuthErrorCode.userNotFound.rawValue)
        
        let result = try! sut.login(email: email, password: password)
            .toArrayAndBlocking()
        let expected: [Event<AuthResponse>] = [.error(AuthError.userNotFound)]
        XCTAssertEqual(result, expected)
    }
    
    func testLoginInvalidEmail() {
        let email = "exampleMail"
        let password = "pass123$42jkKDsad"
        authMock.signInError = NSError(domain: AuthErrorDomain, code: AuthErrorCode.invalidEmail.rawValue)
        
        let result = try! sut.login(email: email, password: password)
            .toArrayAndBlocking()
        let expected: [Event<AuthResponse>] = [.error(AuthError.invalidEmail)]
        XCTAssertEqual(result, expected)
    }
    
    func testLoginWrongPassword() {
        let email = "rafal.wojtus@untitledkingdom.com"
        let password = "pass123$42jkKDsad"
        authMock.signInError = NSError(domain: AuthErrorDomain, code: AuthErrorCode.wrongPassword.rawValue)
        
        let result = try! sut.login(email: email, password: password)
            .toArrayAndBlocking()
        let expected: [Event<AuthResponse>] = [.error(AuthError.wrongPassword)]
        XCTAssertEqual(result, expected)
    }
    
    func testResetPasswordError() {
        let email = "testEmail@uk.com"
        enum TestError: LocalizedError, Equatable {
            case testError
        }
        authMock.passwordResetError = TestError.testError
        
        let result = try! sut.resetPassword(email: email)
            .toArrayAndBlocking()
        XCTAssertEqual(result, .error(TestError.testError))
    }
    
    func testResetPasswordSuccess() {
        let email = "testEmail@uk.com"
        enum TestError: LocalizedError, Equatable {
            case testError
        }
        authMock.passwordResetError = nil
        
        let result = try! sut.resetPassword(email: email)
            .toArrayAndBlocking()
        XCTAssertEqual(result, .completed)
    }
}
