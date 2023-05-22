//
//  AddExerciseScreenInteractorTests.swift
//  FitmaniaTests
//
//  Created by Rafał Wojtuś on 22/05/2023.
//

@testable import Fitmania
import XCTest
import RxSwift
import RxTest
import RxBlocking

final class AddExerciseScreenInteractorTests: XCTestCase {
    
    struct Dependencies: AddExerciseScreenInteractorImpl.Dependencies {
        var exercisesDataStore: ExercisesDataStore { exercisesDataStoreMock }
        let exercisesDataStoreMock = ExercisesDataStoreMock()
        var validationService: ValidationService { validationServiceMock }
        let validationServiceMock =  ValidationServiceMock()
        var workoutsService: WorkoutsService { workoutsServiceMock }
        let workoutsServiceMock = WorkoutsServiceMock()
    }
    
    var dependencies: Dependencies!
    var sut: AddExerciseScreenInteractor!
    var bag: DisposeBag!
    var observer: TestableObserver<AddExerciseScreenResult>!

    override func setUp() {
        dependencies = Dependencies()
        sut = AddExerciseScreenInteractorImpl(dependencies: dependencies, input: AddExerciseScreenBuilderInput.init(chosenExercise: Exercise(category: .triceps, name: "dips")))
        bag = DisposeBag()
        observer = TestScheduler(initialClock: 0).createObserver(AddExerciseScreenResult.self)
    }

    func testAddExercise() {
        sut.addExercise(time: "12", breakTime: "25")
            .subscribe(observer)
            .disposed(by: bag)
        let result = observer.events.compactMap { $0.value.element }
        XCTAssertEqual(result, [.effect(.exerciseAdded)])
    }
    
    func testValidateExerciseTimeSuccess() {
        dependencies.validationServiceMock.validateResponse = .completed
        
        sut.validateExerciseTime(time: "12")
            .subscribe(observer)
            .disposed(by: bag)
        let result = observer.events.compactMap { $0.value.element }
        XCTAssertEqual(result, [.partialState(.exerciseTimeValidationResult(validationMessage: ValidationMessage(message: nil)))])
    }
    
    func testValidateExerciseTimeFailure() {
        let error = TestError.testError
        enum TestError: LocalizedError, Equatable {
            case testError
        }
        dependencies.validationServiceMock.validateResponse = .error(error)
        
        sut.validateExerciseTime(time: "12")
            .subscribe(observer)
            .disposed(by: bag)
        let result = observer.events.compactMap { $0.value.element }
        XCTAssertEqual(result, [.partialState(.exerciseTimeValidationResult(validationMessage: ValidationMessage(message: error.localizedDescription)))])
    }
    
    func testValidateExerciseBreakTimeSuccess() {
        dependencies.validationServiceMock.validateResponse = .completed
        
        sut.validateExerciseBreakTime(time: "12")
            .subscribe(observer)
            .disposed(by: bag)
        let result = observer.events.compactMap { $0.value.element }
        XCTAssertEqual(result, [.partialState(.exerciseBreakTimeValidationResult(validationMessage: ValidationMessage(message: nil)))])
    }
    
    func testValidateExerciseBreakTimeFailure() {
        let error = TestError.testError
        enum TestError: LocalizedError, Equatable {
            case testError
        }
        dependencies.validationServiceMock.validateResponse = .error(error)
        
        sut.validateExerciseBreakTime(time: "12")
            .subscribe(observer)
            .disposed(by: bag)
        let result = observer.events.compactMap { $0.value.element }
        XCTAssertEqual(result, [.partialState(.exerciseBreakTimeValidationResult(validationMessage: ValidationMessage(message: error.localizedDescription)))])
    }
}
