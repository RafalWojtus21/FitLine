//
//  LoginScreenInteractor.swift
//  FitmaniaTests
//
//  Created by Rafał Wojtuś on 20/04/2023.
//

@testable import Fitmania
import XCTest
import RxSwift
import RxTest
import RxBlocking

final class LoginScreenInteractorTests: XCTestCase {
    struct Dependencies: LoginScreenInteractorImpl.Dependencies {
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
    var sut: LoginScreenInteractor!
    
    override func setUp() {
        dependencies = Dependencies()
        sut = LoginScreenInteractorImpl(dependencies: dependencies)
    }
    
    func testValidateEmailObserverSuccess() {
        // Given
        let bag = DisposeBag()
        dependencies.validationServiceMock.validateResponse = .completed
        let scheduler = TestScheduler(initialClock: 0)
        let observer = scheduler.createObserver(LoginScreenResult.self)
        
        // When
        sut.validateEmail(email: "Testemail")
            .subscribe(observer)
            .disposed(by: bag)
        
        // Then
        let result = observer.events.compactMap { $0.value.element  }
        XCTAssertEqual(result, [ .partialState(LoginScreenPartialState.emailValidationResult(validationMessage: .init(message: nil)))])
    }
    
    func testValidateEmailObserverError() {
        // Given
        typealias L = Localization.Validation
        let bag = DisposeBag()
        dependencies.validationServiceMock.validateResponse = .error(Validation.Error(errorDescription: L.passwordUppercaseError))
        let scheduler = TestScheduler(initialClock: 0)
        let observer = scheduler.createObserver(LoginScreenResult.self)
        
        // When
        sut.validateEmail(email: "Testemail")
            .subscribe(observer)
            .disposed(by: bag)
        
        // Then
        let result = observer.events.compactMap { $0.value.element  }
        XCTAssertEqual(result, [ .partialState(LoginScreenPartialState.emailValidationResult(validationMessage: .init(message: L.passwordUppercaseError)))])
    }
    
    func testValidateEmailSubjectSuccess() {
        // Given
        let bag = DisposeBag()
        dependencies.validationServiceMock.validateResponse = .completed
        let subject: BehaviorSubject<LoginScreenResult> = .init(value: .partialState(LoginScreenPartialState.idle))
        
        // When
        sut.validateEmail(email: "Testemail")
            .subscribe(subject)
            .disposed(by: bag)
        
        // Then
        let element = try! subject.value()
        XCTAssertEqual(element, .partialState(LoginScreenPartialState.emailValidationResult(validationMessage: .init(message: nil))))
    }
    
    func testValidatePasswordSubjectSuccess() {
        // Given
        let bag = DisposeBag()
        dependencies.validationServiceMock.validateResponse = .completed
        let subject: BehaviorSubject<LoginScreenResult> = .init(value: .partialState(LoginScreenPartialState.idle))
        
        // When
        sut.validatePassword(password: "somePassword")
            .subscribe(subject)
            .disposed(by: bag)
        
        // Then
        let element = try! subject.value()
        XCTAssertEqual(element, .partialState(LoginScreenPartialState.passwordValidationResult(validationMessage: .init(message: nil))))
    }
    
    func testValidatePasswordObserverSuccess() {
        // Given
        let bag = DisposeBag()
        dependencies.validationServiceMock.validateResponse = .completed
        let scheduler = TestScheduler(initialClock: 0)
        let observer = scheduler.createObserver(LoginScreenResult.self)
        
        // When
        sut.validatePassword(password: "somePassword")
            .subscribe(observer)
            .disposed(by: bag)
        
        // Then
        let result = observer.events.compactMap { $0.value.element  }
        XCTAssertEqual(result, [ .partialState(LoginScreenPartialState.passwordValidationResult(validationMessage: .init(message: nil)))])
    }
    
    func testValidatePasswordObserverError() {
        // Given
        let bag = DisposeBag()
        let errorMessage = "error message"
        dependencies.validationServiceMock.validateResponse = .error(Validation.Error(errorDescription: errorMessage))
        let scheduler = TestScheduler(initialClock: 0)
        let observer = scheduler.createObserver(LoginScreenResult.self)
        
        // When
        sut.validatePassword(password: "somePassword")
            .subscribe(observer)
            .disposed(by: bag)
        
        // Then
        let result = observer.events.compactMap { $0.value.element  }
        XCTAssertEqual(result, [ .partialState(LoginScreenPartialState.passwordValidationResult(validationMessage: .init(message: errorMessage)))])
    }
    
    func testLoginSuccess() {
        let bag = DisposeBag()
        let email = "rafal.wojtus@untitledkingdom.com"
        let password = "somePassword"
        dependencies.authManagerMock.loginAuthResult = .just(AuthResponse(email: email, uid: password))
        let scheduler = TestScheduler(initialClock: 0)
        let observer = scheduler.createObserver(LoginScreenResult.self)
        
        sut.login(email: email, password: password)
            .subscribe(observer)
            .disposed(by: bag)
        
        let result = observer.events.compactMap { $0.value.element }
        XCTAssertEqual(result, [
            .effect(LoginScreenEffect
                .userLoggedIn)])
    }
    
    func testLoginErrorWrongCredentialsAlert() {
        let bag = DisposeBag()
        let email = "rafal.wojtus@untitledkingdom.com"
        let password = "somePassword"
        dependencies.authManagerMock.loginAuthResult = .error(AuthError.wrongPassword)
        let scheduler = TestScheduler(initialClock: 0)
        let observer = scheduler.createObserver(LoginScreenResult.self)
        
        sut.login(email: email, password: password)
            .subscribe(observer)
            .disposed(by: bag)
        
        let result = observer.events.compactMap { $0.value.element }
        XCTAssertEqual(result, [
            .effect(LoginScreenEffect
                .wrongCredentialsAlert(error: AuthError.wrongPassword.errorDescription))])
        XCTAssertNotEqual(result,[
            .effect(LoginScreenEffect
                .userLoggedIn)])
    }
    
    func testLoginErrorSomethingWentWrong() {
        let bag = DisposeBag()
        let email = "rafal.wojtus@untitledkingdom.com"
        let password = "somePassword"
        enum TestError: LocalizedError, Equatable {
            case testError
        }
        
        dependencies.authManagerMock.loginAuthResult = .error(TestError.testError)
        let scheduler = TestScheduler(initialClock: 0)
        let observer = scheduler.createObserver(LoginScreenResult.self)
        
        sut.login(email: email, password: password)
            .subscribe(observer)
            .disposed(by: bag)
        
        let result = observer.events.compactMap { $0.value.element }
        XCTAssertEqual(result, [
            .effect(LoginScreenEffect
                .somethingWentWrong)])
    }
}
