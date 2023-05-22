//
//  CreateAccountScreenInteractorTests.swift
//  FitmaniaTests
//
//  Created by Rafał Wojtuś on 24/04/2023.
//

@testable import Fitmania
import XCTest
import RxSwift
import RxTest
import RxBlocking

final class CreateAccountScreenInteractorTests: XCTestCase {
    struct Dependencies: CreateAccountScreenInteractorImpl.Dependencies {
        var validationService: ValidationService { validationServiceMock }
        var cloudService: CloudService { cloudServiceMock }
        let cloudServiceMock = CloudServiceMock()
        let validationServiceMock = ValidationServiceMock()
    }
    var dependencies: Dependencies!
    var sut: CreateAccountScreenInteractor!
    
    override func setUp() {
        dependencies = Dependencies()
        sut = CreateAccountScreenInteractorImpl(dependencies: dependencies)
    }
    
    func testSaveUserInfoObserverSuccess() {
        // Given
        let bag = DisposeBag()
        dependencies.cloudServiceMock.savePersonalDataResponse = .completed
        let scheduler = TestScheduler(initialClock: 0)
        let observer = scheduler.createObserver(CreateAccountScreenResult.self)
        
        // When
        let userInfo = UserInfo(firstName: "name", lastName: "last name", sex: nil, age: nil, height: 121, weight: nil)
        sut.saveUserInfo(userInfo: userInfo)
            .subscribe(observer)
            .disposed(by: bag)
        
        // Then
        let result = observer.events.compactMap { $0.value.element }
        XCTAssertEqual(result, [
            .effect(CreateAccountScreenEffect
                .showAccountCreatedScreen)
        ])
    }
    
    func testSaveUserInfoObserverError() {
        // Given
        let bag = DisposeBag()
        dependencies.cloudServiceMock.savePersonalDataResponse = .error(AuthError.invalidEmail)
        let scheduler = TestScheduler(initialClock: 0)
        let observer = scheduler.createObserver(CreateAccountScreenResult.self)
        
        // When
        let userInfo = UserInfo(firstName: "1", lastName: "last name", sex: nil, age: nil, height: 121, weight: nil)
        sut.saveUserInfo(userInfo: userInfo)
            .subscribe(observer)
            .disposed(by: bag)
        
        // Then
        let result = observer.events.compactMap { $0.value.element }
        XCTAssertEqual(result, [
            .effect(CreateAccountScreenEffect
                .somethingWentWrong(error: AuthError.invalidEmail.localizedDescription))
        ])
    }
    
    func testValidateFirstNameSuccess() {
        // Given
        let bag = DisposeBag()
        dependencies.validationServiceMock.validateResponse = .completed
        let subject: BehaviorSubject<CreateAccountScreenResult> =
            .init(value: .partialState(CreateAccountScreenPartialState
                .firstNameValidationResult(validationMessage: .init(message: "tests message"))))
        
        // When
        sut.validateName(name: "name")
            .subscribe(subject)
            .disposed(by: bag)
        
        // Then
        let element = try! subject.value()
        XCTAssertEqual(element, .partialState(CreateAccountScreenPartialState
            .firstNameValidationResult(validationMessage: .init(message: nil))))
    }
    
    func testValidateFirstNameError() {
        // Given
        let bag = DisposeBag()
        let error = AuthError.invalidEmail
        dependencies.validationServiceMock.validateResponse = .error(error)
        let subject: BehaviorSubject<CreateAccountScreenResult> =
            .init(value: .partialState(CreateAccountScreenPartialState
                .firstNameValidationResult(validationMessage: .init(message: "tests message"))))
        
        // When
        sut.validateName(name: "name")
            .subscribe(subject)
            .disposed(by: bag)
        
        // Then
        let element = try! subject.value()
        XCTAssertEqual(element, .partialState(CreateAccountScreenPartialState
            .firstNameValidationResult(validationMessage: .init(message: error.localizedDescription))))
    }
    
    func testValidateLastNameSuccess() {
        // Given
        let bag = DisposeBag()
        dependencies.validationServiceMock.validateResponse = .completed
        let subject: BehaviorSubject<CreateAccountScreenResult> =
            .init(value: .partialState(CreateAccountScreenPartialState
                .lastNameValidationResult(validationMessage: .init(message: "tests message"))))
        
        // When
        sut.validateLastName(lastName: "name")
            .subscribe(subject)
            .disposed(by: bag)
        
        // Then
        let element = try! subject.value()
        XCTAssertEqual(element, .partialState(CreateAccountScreenPartialState
            .lastNameValidationResult(validationMessage: .init(message: nil))))
    }
    
    func testValidateLastNameError() {
        // Given
        let bag = DisposeBag()
        let error = AuthError.invalidEmail
        dependencies.validationServiceMock.validateResponse = .error(error)
        let subject: BehaviorSubject<CreateAccountScreenResult> =
            .init(value: .partialState(CreateAccountScreenPartialState
                .lastNameValidationResult(validationMessage: .init(message: "tests message"))))
        
        // When
        sut.validateLastName(lastName: "name")
            .subscribe(subject)
            .disposed(by: bag)
        
        // Then
        let element = try! subject.value()
        XCTAssertEqual(element, .partialState(CreateAccountScreenPartialState
            .lastNameValidationResult(validationMessage: .init(message: error.localizedDescription))))
    }
    
    func testValidateAgeSuccess() {
        // Given
        let bag = DisposeBag()
        dependencies.validationServiceMock.validateResponse = .completed
        let subject: BehaviorSubject<CreateAccountScreenResult> =
            .init(value: .partialState(CreateAccountScreenPartialState
                .ageValidationResult(validationMessage: .init(message: "tests message"))))
        
        // When
        sut.validateAge(age: "54")
            .subscribe(subject)
            .disposed(by: bag)
        
        // Then
        let element = try! subject.value()
        XCTAssertEqual(element, .partialState(CreateAccountScreenPartialState
            .ageValidationResult(validationMessage: .init(message: nil))))
    }
    
    func testValidateAgeError() {
        // Given
        let bag = DisposeBag()
        let error = AuthError.invalidEmail
        dependencies.validationServiceMock.validateResponse = .error(error)
        let subject: BehaviorSubject<CreateAccountScreenResult> =
            .init(value: .partialState(CreateAccountScreenPartialState
                .ageValidationResult(validationMessage: .init(message: "tests message"))))
        
        // When
        sut.validateAge(age: "21")
            .subscribe(subject)
            .disposed(by: bag)
        
        // Then
        let element = try! subject.value()
        XCTAssertEqual(element, .partialState(CreateAccountScreenPartialState
            .ageValidationResult(validationMessage: .init(message: error.localizedDescription))))
    }
    
    func testValidateHeightSuccess() {
        // Given
        let bag = DisposeBag()
        dependencies.validationServiceMock.validateResponse = .completed
        let subject: BehaviorSubject<CreateAccountScreenResult> =
            .init(value: .partialState(CreateAccountScreenPartialState
                .heightValidationResult(validationMessage: .init(message: "tests message"))))
        
        // When
        sut.validateHeight(height: "321312")
            .subscribe(subject)
            .disposed(by: bag)
        
        // Then
        let element = try! subject.value()
        XCTAssertEqual(element, .partialState(CreateAccountScreenPartialState
            .heightValidationResult(validationMessage: .init(message: nil))))
    }
    
    func testValidateHeightError() {
        // Given
        let bag = DisposeBag()
        dependencies.validationServiceMock.validateResponse = .error(Validation.Error(errorDescription: Localization.Validation.invalidHeightError))
        let subject: BehaviorSubject<CreateAccountScreenResult> =
            .init(value: .partialState(CreateAccountScreenPartialState
                .ageValidationResult(validationMessage: .init(message: "tests message"))))
        
        // When
        sut.validateAge(age: "5423")
            .subscribe(subject)
            .disposed(by: bag)
        
        // Then
        let element = try! subject.value()
        XCTAssertNotEqual(element, .partialState(CreateAccountScreenPartialState
            .ageValidationResult(validationMessage: .init(message: nil))))
        XCTAssertEqual(element, .partialState(CreateAccountScreenPartialState
            .ageValidationResult(validationMessage: .init(message: Localization.Validation.invalidHeightError))))
    }
    
    func testValidateWeightSuccess() {
        // Given
        let bag = DisposeBag()
        dependencies.validationServiceMock.validateResponse = .completed
        let subject: BehaviorSubject<CreateAccountScreenResult> =
            .init(value: .partialState(CreateAccountScreenPartialState
                .weightValidationResult(validationMessage: .init(message: "tests message"))))
        
        // When
        sut.validateWeight(weight: "321312")
            .subscribe(subject)
            .disposed(by: bag)
        
        // Then
        let element = try! subject.value()
        XCTAssertEqual(element, .partialState(CreateAccountScreenPartialState
            .weightValidationResult(validationMessage: .init(message: nil))))
    }
    
    func testValidateWeightError() {
        // Given
        let bag = DisposeBag()
        dependencies.validationServiceMock.validateResponse = .error(Validation.Error(errorDescription: Localization.Validation.invalidHeightError))
        let subject: BehaviorSubject<CreateAccountScreenResult> =
            .init(value: .partialState(CreateAccountScreenPartialState
                .weightValidationResult(validationMessage: .init(message: "tests message"))))
        
        // When
        sut.validateWeight(weight: "5423")
            .subscribe(subject)
            .disposed(by: bag)
        
        // Then
        let element = try! subject.value()
        XCTAssertNotEqual(element, .partialState(CreateAccountScreenPartialState
            .weightValidationResult(validationMessage: .init(message: nil))))
        XCTAssertEqual(element, .partialState(CreateAccountScreenPartialState
            .weightValidationResult(validationMessage: .init(message: Localization.Validation.invalidHeightError))))
    }

    func testValidateSexSuccess() {
        // Given
        let bag = DisposeBag()
        dependencies.validationServiceMock.validateResponse = .completed
        let subject: BehaviorSubject<CreateAccountScreenResult> =
            .init(value: .partialState(CreateAccountScreenPartialState
                .sexValidationResult(validationMessage: .init(message: "tests message"))))
        
        // When
        sut.validateSex(sex: "321312")
            .subscribe(subject)
            .disposed(by: bag)
        
        // Then
        let element = try! subject.value()
        XCTAssertEqual(element, .partialState(CreateAccountScreenPartialState
            .sexValidationResult(validationMessage: .init(message: nil))))
    }
    
    func testValidateSexError() {
        // Given
        let bag = DisposeBag()
        dependencies.validationServiceMock.validateResponse = .error(Validation.Error(errorDescription: Localization.Validation.invalidHeightError))
        let subject: BehaviorSubject<CreateAccountScreenResult> =
            .init(value: .partialState(CreateAccountScreenPartialState
                .sexValidationResult(validationMessage: .init(message: "tests message"))))
        
        // When
        sut.validateSex(sex: "5423")
            .subscribe(subject)
            .disposed(by: bag)
        
        // Then
        let element = try! subject.value()
        XCTAssertNotEqual(element, .partialState(CreateAccountScreenPartialState
            .sexValidationResult(validationMessage: .init(message: nil))))
        XCTAssertEqual(element, .partialState(CreateAccountScreenPartialState
            .sexValidationResult(validationMessage: .init(message: Localization.Validation.invalidHeightError))))
    }
}
