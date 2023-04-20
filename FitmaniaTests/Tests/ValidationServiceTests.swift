//
//  ValidationServiceTests.swift
//  FitmaniaTests
//
//  Created by Rafał Wojtuś on 20/04/2023.
//

@testable import Fitmania
import XCTest
import RxSwift
import RxTest
import RxBlocking

final class ValidationServiceTests: XCTestCase {
    var sut: ValidationService!
    
    override func setUp() {
        sut = ValidationServiceImpl()
    }
    
    func testEmailValidationInvalidEmailError() {
        let result = try! sut.validate(.email, input: "test.o2")
            .asObservable()
            .materialize()
            .toArray()
            .toBlocking()
            .single()
        XCTAssertEqual(result, [.error(Validation.Error(errorDescription: Localization.Validation.invalidEmailError))])
    }
    
    func testEmailValidationEmptyEmailError() {
        let result = try! sut.validate(.email, input: "")
            .asObservable()
            .materialize()
            .toArray()
            .toBlocking()
            .single()
        XCTAssertEqual(result, [.error(Validation.Error(errorDescription: Localization.Validation.emptyFieldError + " " + Validation.ValidationType.email.rawValue))])
    }
    
    func testEmailValidationSuccess() {
        let result = try! sut.validate(.email, input: "testmail@uk.com")
            .asObservable()
            .materialize()
            .toArray()
            .toBlocking()
            .single()
        XCTAssertEqual(result, [.completed])
    }
    
    func testEmailValidationObserver() {
        // Given
        let bag = DisposeBag()
        let scheduler = TestScheduler(initialClock: 0)
        let observer = scheduler.createObserver(CompletableEvent.self)
        
        //When
        sut.validate(.email, input: "test.o2")
            .subscribe(onCompleted: {
                observer.onNext(.completed)
            }, onError: {
                observer.onError($0)
            })
            .disposed(by: bag)
        scheduler.start()
        
        // Then
        let result = observer.events.compactMap { $0.value.error?.localizedDescription }
        XCTAssertEqual(result, [Localization.Validation.invalidEmailError])
    }
    
    func testPasswordValidationCharacterError() {
        let result = try! sut.validate(.password, input: "Qwerty123")
            .asObservable()
            .materialize()
            .toArray()
            .toBlocking()
            .single()
        XCTAssertEqual(result, [.error(Validation.Error(errorDescription: Localization.Validation.passwordCharacterError))])
    }
    
    func testPasswordValidationUppercaseError() {
        let result = try! sut.validate(.password, input: "qere@werty123")
            .asObservable()
            .materialize()
            .toArray()
            .toBlocking()
            .single()
        XCTAssertEqual(result, [.error(Validation.Error(errorDescription: Localization.Validation.passwordUppercaseError))])
    }
    
    func testPasswordValidationLowercaseError() {
        let result = try! sut.validate(.password, input: "QWERTY@$#123")
            .asObservable()
            .materialize()
            .toArray()
            .toBlocking()
            .single()
        XCTAssertEqual(result, [.error(Validation.Error(errorDescription: Localization.Validation.passwordLowerCaseError))])
    }
    
    func testPasswordValidationDigitError() {
        let result = try! sut.validate(.password, input: "Qwertyjk@#$#@$@#KF")
            .asObservable()
            .materialize()
            .toArray()
            .toBlocking()
            .single()
        XCTAssertEqual(result, [.error(Validation.Error(errorDescription: Localization.Validation.passwordDigitError))])
    }
    
    func testPasswordValidationLengthError() {
        let shortPassword = try! sut.validate(.password, input: "A@b1")
            .asObservable()
            .materialize()
            .toArray()
            .toBlocking()
            .single()
        XCTAssertEqual(shortPassword, [.error(Validation.Error(errorDescription: Localization.Validation.passwordLengthError))])
    }
    
    func testPasswordValidationSuccess() {
        let result = try! sut.validate(.password, input: "Qwerty12345@##2")
            .asObservable()
            .materialize()
            .toArray()
            .toBlocking()
            .single()
        XCTAssertEqual(result, [.completed])
    }
}
