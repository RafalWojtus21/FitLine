//
//  WorkoutSetupScreenInteractorTests.swift
//  FitmaniaTests
//
//  Created by Rafał Wojtuś on 22/05/2023.
//

@testable import Fitmania
import XCTest
import RxSwift
import RxTest
import RxBlocking

final class WorkoutSetupScreenInteractorTests: XCTestCase {
    
    struct Dependencies: WorkoutSetupScreenInteractorImpl.Dependencies {
        var exercisesDataStore: ExercisesDataStore { exercisesDataStoreMock }
        let exercisesDataStoreMock = ExercisesDataStoreMock()
        var workoutsService: WorkoutsService { workoutsServiceMock }
        let workoutsServiceMock = WorkoutsServiceMock()
    }
    
    var dependencies: Dependencies!
    var sut: WorkoutSetupScreenInteractor!
    var bag: DisposeBag!
    var observer: TestableObserver<WorkoutSetupScreenResult>!

    override func setUp() {
        dependencies = Dependencies()
        sut = WorkoutSetupScreenInteractorImpl(dependencies: dependencies, input: WorkoutSetupScreenBuilderInput(trainingName: "trainingName"))
        bag = DisposeBag()
        observer = TestScheduler(initialClock: 0).createObserver(WorkoutSetupScreenResult.self)
    }

    func testSetWorkoutData() {
        sut.setWorkoutData()
            .subscribe(observer)
            .disposed(by: bag)
        let result = observer.events.compactMap { $0.value.element }
        XCTAssertEqual(result, [
            .effect(.workoutNameSet)])
    }
    
    func testLoadExercises() {
        let plans: [WorkoutPart] = [WorkoutPart(workoutPlanName: "plan 1", workoutPlanID: WorkoutPlanID(workoutPlanID: UUID()), exercise: Exercise(category: .cardio, name: "running"), details: WorkoutPart.Details(sets: nil, time: 12, breakTime: 24))]
        dependencies.exercisesDataStoreMock.exercisesRelay.accept(plans)

        sut.loadExercises()
            .subscribe(observer)
            .disposed(by: bag)
        
        let result = observer.events.compactMap { $0.value.element }

        XCTAssertEqual(result, [.partialState(.loadExercises(exercises: plans))])
    }
    
    func testSaveWorkoutToDatabaseSuccess() {
        dependencies.workoutsServiceMock.saveNewPersonalPlanResponse = .completed
        
        sut.saveWorkoutToDatabase()
            .subscribe(observer)
            .disposed(by: bag)
        
        let result = observer.events.compactMap { $0.value.element }
        XCTAssertEqual(result, [.effect(.workoutSaved)])
    }
    
    func testSaveWorkoutToDatabaseFailure() {
        enum TestError: LocalizedError, Equatable {
            case testError
        }
        
        dependencies.workoutsServiceMock.saveNewPersonalPlanResponse = .error(TestError.testError)
        
        sut.saveWorkoutToDatabase()
            .subscribe(observer)
            .disposed(by: bag)
        
        let result = observer.events.compactMap { $0.value.element }
        XCTAssertEqual(result, [.effect(.somethingWentWrong)])
    }
}
