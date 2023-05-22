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
    var bag: DisposeBag!
    var observer: TestableObserver<RegisterScreenResult>!
    
    override func setUp() {
        dependencies = Dependencies()
        sut = RegisterScreenInteractorImpl(dependencies: dependencies)
        bag = DisposeBag()
        observer = TestScheduler(initialClock: 0).createObserver(RegisterScreenResult.self)
    }
    
    func testValidateEmailObserverSuccess() {
        // Given
        dependencies.validationServiceMock.validateResponse = .completed
        
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
        let errorMessage = "text"
        dependencies.validationServiceMock.validateResponse = .error(Validation.Error(errorDescription: errorMessage))
        
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
        let errorMessage = "error message"
        dependencies.validationServiceMock.validateResponse = .error(Validation.Error(errorDescription: errorMessage))
        
        // When
        sut.validatePassword(password: "somePassword")
            .subscribe(observer)
            .disposed(by: bag)
        
        // Then
        let result = observer.events.compactMap { $0.value.element  }
        XCTAssertEqual(result, [ .partialState(RegisterScreenPartialState.passwordValidationResult(validationMessage: .init(message: errorMessage)))])
    }
    
    func testValidateRepeatPasswordError() {
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
        let email = "rafal.wojtus@untitledkingdom.com"
        let password = "somePassword"
        dependencies.authManagerMock.signUpAuthResult = .just(AuthResponse(email: email, uid: password))
        
        sut.register(email: email, password: password)
            .subscribe(observer)
            .disposed(by: bag)
        
        let result = observer.events.compactMap { $0.value.element }
        XCTAssertEqual(result, [
            .effect(RegisterScreenEffect
                .showAccountSetupScreen)])
    }
    
    func testRegisterError() {
        let email = "rafal.wojtus@untitledkingdom.com"
        let password = "somePassword"
        dependencies.authManagerMock.signUpAuthResult = .error(AuthError.emailAlreadyInUse)
        
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
        let email = "rafal.wojtus@untitledkingdom.com"
        let password = "somePassword"
        
        enum TestError: LocalizedError, Equatable {
            case testError
        }
        
        dependencies.authManagerMock.signUpAuthResult = .error(TestError.testError)
        
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
