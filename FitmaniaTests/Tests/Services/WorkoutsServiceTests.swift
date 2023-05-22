//
//  WorkoutsServiceTests.swift
//  FitmaniaTests
//
//  Created by Rafał Wojtuś on 22/05/2023.
//

@testable import Fitmania
import XCTest
import RxSwift
import RxTest
import RxBlocking

final class WorkoutsServiceTests: XCTestCase {
    var sut: WorkoutsService!
    var cloudServiceMock: CloudServiceMock!
    
    override func setUp() {
        cloudServiceMock = CloudServiceMock()
        sut = WorkoutsServiceImpl(cloudService: cloudServiceMock)
    }
    
    func testSaveNewPersonalTrainingPlanInvalidWorkoutPlan() {
        cloudServiceMock.savePersonalDataWithIDResponse = .completed
        let result = try! sut.saveNewPersonalTrainingPlan(exercises: [])
            .toArrayAndBlocking()
        XCTAssertEqual(result, .error(DatabaseError.invalidWorkoutPlan))
    }
    
    func testSaveNewPersonalTrainingPlanError() {
        enum TestError: LocalizedError, Equatable {
            case testError
        }
        let error = TestError.testError
        cloudServiceMock.savePersonalDataWithIDResponse = .error(error)
        let plan1Name = "plan1"
        let plan1ID = WorkoutPlanID(workoutPlanID: UUID())
        let exercises: [WorkoutPart] = [WorkoutPart(workoutPlanName: plan1Name, workoutPlanID: plan1ID, exercise: Exercise(category: .legs, name: "squats"), time: 12, breakTime: 24), WorkoutPart(workoutPlanName: plan1Name, workoutPlanID: plan1ID, exercise: Exercise(category: .chest, name: "push ups"), time: 22, breakTime: 25)]
        let result = try! sut.saveNewPersonalTrainingPlan(exercises: exercises)
            .toArrayAndBlocking()
        XCTAssertEqual(result, .error(error))
    }
    
    func testSaveNewPersonalTrainingPlanSuccess() {
        enum TestError: LocalizedError, Equatable {
            case testError
        }
        cloudServiceMock.savePersonalDataWithIDResponse = .completed
        let plan1Name = "plan1"
        let plan1ID = WorkoutPlanID(workoutPlanID: UUID())
        let exercises: [WorkoutPart] = [WorkoutPart(workoutPlanName: plan1Name, workoutPlanID: plan1ID, exercise: Exercise(category: .legs, name: "squats"), time: 12, breakTime: 24), WorkoutPart(workoutPlanName: plan1Name, workoutPlanID: plan1ID, exercise: Exercise(category: .chest, name: "push ups"), time: 22, breakTime: 25)]
        let result = try! sut.saveNewPersonalTrainingPlan(exercises: exercises)
            .toArrayAndBlocking()
        XCTAssertEqual(result, .completed)
    }
    
    func testFetchAllExercises() {
        let exercises = [WorkoutPart(workoutPlanName: "plan Name", workoutPlanID: WorkoutPlanID(workoutPlanID: UUID()), exercise: Exercise(category: .cardio, name: "running"), time: 12, breakTime: 25), WorkoutPart(workoutPlanName: "plan Name 2", workoutPlanID: WorkoutPlanID(workoutPlanID: UUID()), exercise: Exercise(category: .cardio, name: "hiking"), time: 222, breakTime: 253)]
        cloudServiceMock.fetchPersonalDataSingleResponse = .just(exercises)
        let result = try! sut.fetchAllExercises()
            .toArrayAndBlocking()
        let expected: [Event<[WorkoutPart]>] = [.next(exercises), .completed]
        XCTAssertEqual(result, expected)
    }
    
    func testFetchAllWorkoutsError() {
        let exercises = [WorkoutPart(workoutPlanName: "plan Name", workoutPlanID: WorkoutPlanID(workoutPlanID: UUID()), exercise: Exercise(category: .cardio, name: "running"), time: 12, breakTime: 25), WorkoutPart(workoutPlanName: "plan Name 2", workoutPlanID: WorkoutPlanID(workoutPlanID: UUID()), exercise: Exercise(category: .cardio, name: "hiking"), time: 222, breakTime: 253)]
        cloudServiceMock.fetchPersonalDataObservableResponse = .just(exercises)
        let result = try! sut.fetchAllWorkouts()
            .toArrayAndBlocking()
        
        let expected: [Event<[WorkoutPart]>] = [.next(exercises), .completed]
        XCTAssertEqual(result, expected)
    }
    
    func testDeleteWorkoutPlanSuccess() {
        cloudServiceMock.deletePersonalDataWithIDResponse = .completed
        let id = WorkoutPlanID(workoutPlanID: UUID())
        let result = try! sut.deleteWorkoutPlan(id: id)
            .toArrayAndBlocking()
        XCTAssertEqual(result, .completed)
    }
    
    func testDeleteWorkoutPlanError() {
        enum TestError: LocalizedError, Equatable {
            case testError
        }
        let error = TestError.testError
        cloudServiceMock.deletePersonalDataWithIDResponse = .error(error)
        let id = WorkoutPlanID(workoutPlanID: UUID())
        let result = try! sut.deleteWorkoutPlan(id: id)
            .toArrayAndBlocking()
        XCTAssertEqual(result, .error(error))
    }
    
    func testObserveWorkoutsInCloudService() {
        // should I test it?
    }
    
    func testWorkoutsObservable() {
    }
}
