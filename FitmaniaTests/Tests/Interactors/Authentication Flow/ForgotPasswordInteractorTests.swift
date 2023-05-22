//
//  ForgotPasswordInteractorTests.swift
//  FitmaniaTests
//
//  Created by Rafał Wojtuś on 24/04/2023.
//

@testable import Fitmania
import XCTest
import RxSwift
import RxTest
import RxBlocking

final class ForgotPasswordScreenInteractorTests: XCTestCase {
    struct Dependencies: ForgotPasswordScreenInteractorImpl.Dependencies {
        var authManager: AuthManager { authManagerMock }
        var validationService: ValidationService { validationServiceMock }
        let authManagerMock = AuthManagerMock()
        let validationServiceMock = ValidationServiceMock()
    }
    var dependencies: Dependencies!
    var sut: ForgotPasswordScreenInteractor!
    
    override func setUp() {
        dependencies = Dependencies()
        sut = ForgotPasswordScreenInteractorImpl(dependencies: dependencies)
    }
    
    func testResetPasswordSuccess() {
        let bag = DisposeBag()
        let scheduler = TestScheduler(initialClock: 0)
        let observer = scheduler.createObserver(ForgotPasswordScreenResult.self)
        dependencies.authManagerMock.resetResponse = .completed
        sut.resetPassword(email: "testEmail@gmail.com")
            .subscribe(observer)
            .disposed(by: bag)
        
        let result = observer.events.compactMap { $0.value.element }
        XCTAssertEqual(result, [
            .effect(ForgotPasswordScreenEffect
                .emailSent)])
    }
    
    func testResetPasswordError() {
        let bag = DisposeBag()
        let scheduler = TestScheduler(initialClock: 0)
        let observer = scheduler.createObserver(ForgotPasswordScreenResult.self)
        dependencies.authManagerMock.resetResponse = .error(AuthError.invalidEmail)
        sut.resetPassword(email: "testEmail@gmail.com")
            .subscribe(observer)
            .disposed(by: bag)
        
        let result = observer.events.compactMap { $0.value.element }
        XCTAssertEqual(result, [
            .effect(ForgotPasswordScreenEffect
                .passwordResetError(error: AuthError.invalidEmail.errorDescription))])
    }
    
    func testResetPasswordErrorSomethingWentWrong() {
        let bag = DisposeBag()
        let scheduler = TestScheduler(initialClock: 0)
        let observer = scheduler.createObserver(ForgotPasswordScreenResult.self)
        enum TestError: LocalizedError, Equatable {
            case testError
        }
        dependencies.authManagerMock.resetResponse = .error(TestError.testError)
        sut.resetPassword(email: "testEmail@gmail.com")
            .subscribe(observer)
            .disposed(by: bag)
        
        let result = observer.events.compactMap { $0.value.element }
        XCTAssertEqual(result, [
            .effect(ForgotPasswordScreenEffect
                .somethingWentWrong)])
    }
    
    func testValidateEmailObserverSuccess() {
        // Given
        let bag = DisposeBag()
        dependencies.validationServiceMock.validateResponse = .completed
        let scheduler = TestScheduler(initialClock: 0)
        let observer = scheduler.createObserver(ForgotPasswordScreenResult.self)
        
        // When
        sut.validateEmail(email: "Testemail")
            .subscribe(observer)
            .disposed(by: bag)
        
        // Then
        let result = observer.events.compactMap { $0.value.element  }
        XCTAssertEqual(result, [ .partialState(ForgotPasswordScreenPartialState.emailValidationResult(validationMessage: .init(message: nil)))])
    }
    
    func testValidateEmailObserverError() {
        // Given
        let bag = DisposeBag()
        let errorMessage = "someMessage"
        dependencies.validationServiceMock.validateResponse = .error(Validation.Error(errorDescription: errorMessage))
        let scheduler = TestScheduler(initialClock: 0)
        let observer = scheduler.createObserver(ForgotPasswordScreenResult.self)
        
        // When
        sut.validateEmail(email: "Testemail")
            .subscribe(observer)
            .disposed(by: bag)
        
        // Then
        let result = observer.events.compactMap { $0.value.element  }
        XCTAssertEqual(result, [ .partialState(ForgotPasswordScreenPartialState.emailValidationResult(validationMessage: .init(message: errorMessage)))])
    }
}
