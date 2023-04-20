//
//  RegisterScreenInteractor.swift
//  FitmaniaTests
//
//  Created by Rafał Wojtuś on 24/04/2023.
//

@testable import Fitmania
import XCTest
import RxSwift
import RxTest
import RxBlocking

final class RegisterScreenInteractorTests: XCTestCase {
    struct Dependencies: RegisterScreenInteractorImpl.Dependencies {
        var authManager: AuthManager {
            authManagerMock
        }
        var validationService: ValidationService {
            validationServiceMock
        }
        let authManagerMock = AuthManagerMock()
        let validationServiceMock = ValidationServiceMock()
    }
    var dependencies: Dependencies!
    var sut: RegisterScreenInteractor!
    
    override func setUp() {
        dependencies = Dependencies()
        sut = RegisterScreenInteractorImpl(dependencies: dependencies)
    }
    
    func testValidateEmailObserverSuccess() {
        // Given
        let bag = DisposeBag()
        dependencies.validationServiceMock.validateResponse = .completed
        let scheduler = TestScheduler(initialClock: 0)
        let observer = scheduler.createObserver(RegisterScreenResult.self)
        
        // When
        sut.validateEmail(email: "Testemail")
            .subscribe(observer)
            .disposed(by: bag)
        
        // Then
        let result = observer.events.compactMap { $0.value.element  }
        XCTAssertEqual(result, [ .partialState(RegisterScreenPartialState.emailValidationResult(validationMessage: .init(message: nil)))])
    }
    
    func testValidateEmailObserverError() {
        // Given
        let bag = DisposeBag()
        let errorMessage = "text"
        dependencies.validationServiceMock.validateResponse = .error(Validation.Error(errorDescription: errorMessage))
        let scheduler = TestScheduler(initialClock: 0)
        let observer = scheduler.createObserver(RegisterScreenResult.self)
        
        // When
        sut.validateEmail(email: "Testemail")
            .subscribe(observer)
            .disposed(by: bag)
        
        // Then
        let result = observer.events.compactMap { $0.value.element  }
        XCTAssertEqual(result, [ .partialState(RegisterScreenPartialState.emailValidationResult(validationMessage: .init(message: errorMessage)))])
    }

    
    func testValidatePasswordSubjectSuccess() {
        // Given
        let bag = DisposeBag()
        dependencies.validationServiceMock.validateResponse = .completed
        let subject: BehaviorSubject<RegisterScreenResult> = .init(value: .partialState(RegisterScreenPartialState.passwordValidationResult(validationMessage: ValidationMessage(message: "Tests message"))))
        
        // When
        sut.validatePassword(password: "Zaq1@x3kjs")
            .subscribe(subject)
            .disposed(by: bag)
        
        // Then
        let element = try! subject.value()
        XCTAssertEqual(element, .partialState(RegisterScreenPartialState
            .passwordValidationResult(validationMessage: .init(message: nil))))
    }
    
    func testValidatePasswordObserverError() {
        // Given
        let bag = DisposeBag()
        let errorMessage = "error message"
        dependencies.validationServiceMock.validateResponse = .error(Validation.Error(errorDescription: errorMessage))
        let scheduler = TestScheduler(initialClock: 0)
        let observer = scheduler.createObserver(RegisterScreenResult.self)
        
        // When
        sut.validatePassword(password: "somePassword")
            .subscribe(observer)
            .disposed(by: bag)
        
        // Then
        let result = observer.events.compactMap { $0.value.element  }
        XCTAssertEqual(result, [ .partialState(RegisterScreenPartialState.passwordValidationResult(validationMessage: .init(message: errorMessage)))])
    }
    
    func testValidateRepeatPasswordError() {
        // Given
        let bag = DisposeBag()
        let scheduler = TestScheduler(initialClock: 0)
        let observer = scheduler.createObserver(RegisterScreenResult.self)
        
        // When
        sut.validateRepeatPassword(password: "somePassword", repeatPassword: "somePassword1")
            .subscribe(observer)
            .disposed(by: bag)
        
        let result = observer.events.compactMap { $0.value.element }
        XCTAssertEqual(result, [
            .partialState(RegisterScreenPartialState
                .repeatPasswordValidationResult(validationMessage: .init(message: Localization.Validation.repeatPasswordError)))
        ])
    }
    
    func testValidateRepeatPasswordSuccess() {
        // Given
        let bag = DisposeBag()
        let scheduler = TestScheduler(initialClock: 0)
        let observer = scheduler.createObserver(RegisterScreenResult.self)
        
        // When
        sut.validateRepeatPassword(password: "somePassword", repeatPassword: "somePassword")
            .subscribe(observer)
            .disposed(by: bag)
        
        let result = observer.events.compactMap { $0.value.element }
        XCTAssertEqual(result, [
            .partialState(RegisterScreenPartialState
                .repeatPasswordValidationResult(validationMessage: .init(message: nil)))
        ])
    }
    
    func testRegisterSuccess() {
        let bag = DisposeBag()
        let email = "rafal.wojtus@untitledkingdom.com"
        let password = "somePassword"
        dependencies.authManagerMock.signUpAuthResult = .just(AuthResponse(email: email, uid: password))
        let scheduler = TestScheduler(initialClock: 0)
        let observer = scheduler.createObserver(RegisterScreenResult.self)
        
        sut.register(email: email, password: password)
            .subscribe(observer)
            .disposed(by: bag)
        
        let result = observer.events.compactMap { $0.value.element }
        XCTAssertEqual(result, [
            .effect(RegisterScreenEffect
                .showAccountSetupScreen)])
    }
    
    func testRegisterError() {
        let bag = DisposeBag()
        let email = "rafal.wojtus@untitledkingdom.com"
        let password = "somePassword"
        dependencies.authManagerMock.signUpAuthResult = .error(AuthError.emailAlreadyInUse)
        let scheduler = TestScheduler(initialClock: 0)
        let observer = scheduler.createObserver(RegisterScreenResult.self)
        
        sut.register(email: email, password: password)
            .subscribe(observer)
            .disposed(by: bag)
        
        let result = observer.events.compactMap { $0.value.element }
        XCTAssertEqual(result, [
            .effect(RegisterScreenEffect
                .registerError(error: AuthError.emailAlreadyInUse.errorDescription))])
        XCTAssertNotEqual(result,[
            .effect(RegisterScreenEffect
                .showAccountSetupScreen)])
    }
    
    func testRegisterErrorSomethingWentWrong() {
        let bag = DisposeBag()
        let email = "rafal.wojtus@untitledkingdom.com"
        let password = "somePassword"
        
        enum TestError: LocalizedError, Equatable {
            case testError
        }
        
        dependencies.authManagerMock.signUpAuthResult = .error(TestError.testError)
        let scheduler = TestScheduler(initialClock: 0)
        let observer = scheduler.createObserver(RegisterScreenResult.self)
        
        sut.register(email: email, password: password)
            .subscribe(observer)
            .disposed(by: bag)
        
        let result = observer.events.compactMap { $0.value.element }
        XCTAssertEqual(result, [
            .effect(RegisterScreenEffect
                .somethingWentWrong)])
        XCTAssertNotEqual(result,[
            .effect(RegisterScreenEffect
                .showAccountSetupScreen)])
    }
}
