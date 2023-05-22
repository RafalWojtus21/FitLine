//
//  CloudServiceTests.swift
//  FitmaniaTests
//
//  Created by Rafał Wojtuś on 22/05/2023.
//

@testable import Fitmania
import XCTest
import RxSwift
import RxTest
import RxBlocking
import FirebaseAuth

final class CloudServiceTests: XCTestCase {
    var sut: CloudService!
    var authManagerMock: AuthManagerMock!
    var realtimeServiceMock: RealtimeDatabaseServiceMock!
    
    override func setUp() {
        authManagerMock = AuthManagerMock()
        realtimeServiceMock = RealtimeDatabaseServiceMock()
        sut = CloudServiceImpl(authManager: authManagerMock, realtimeService: realtimeServiceMock)
    }
    
    let plan1Name = "plan 1"
    let plan1ID = WorkoutPlanID(workoutPlanID: UUID())
    let plan2Name = "plan 2"
    let plan2ID = WorkoutPlanID(workoutPlanID: UUID())
    
    var testData: [WorkoutPart] {
        [WorkoutPart(workoutPlanName: plan1Name, workoutPlanID: plan1ID, exercise: Exercise(category: .chest, name: "push ups"), time: 12, breakTime: 25), WorkoutPart(workoutPlanName: plan2Name, workoutPlanID: plan2ID, exercise: Exercise(category: .back, name: "rowing"), time: 112, breakTime: 12312)]
    }
    
    enum TestError: LocalizedError, Equatable {
        case testError
    }
    
    func testSavePublicDataSuccess() {
        realtimeServiceMock.saveResponse = .completed
        let result = try! sut.savePublicData(data: testData, endpoint: .workouts)
            .toArrayAndBlocking()
        XCTAssertEqual(result, .completed)
    }
    
    func testSavePublicDataError() {
        let error = TestError.testError
        realtimeServiceMock.saveResponse = .error(error)
        let result = try! sut.savePublicData(data: testData, endpoint: .workouts)
            .toArrayAndBlocking()
        XCTAssertEqual(result, .error(error))
    }
    
    func testSavePersonalDataUnauthenticatedUser() {
        realtimeServiceMock.saveResponse = .completed
        let result = try! sut.savePersonalData(data: testData, endpoint: .workoutsPublic)
            .toArrayAndBlocking()
        XCTAssertEqual(result, .error(AuthError.unauthenticatedUser))
    }
    
    func testSavePersonalDataWithIDError() {
        realtimeServiceMock.saveResponse = .completed
        let result = try! sut.savePersonalDataWithID(data: testData, endpoint: .workoutsPublic, id: UUID())
            .toArrayAndBlocking()
        XCTAssertEqual(result, .error(AuthError.unauthenticatedUser))
    }
    
    func testSavePersonalDataWithIDNoID() {
        realtimeServiceMock.saveResponse = .completed
        let result = try! sut.savePersonalDataWithID(data: testData, endpoint: .workoutsPublic, id: nil)
            .toArrayAndBlocking()
        XCTAssertEqual(result, .error(AuthError.unauthenticatedUser))
    }
    
    func testFetchPublicDataSingleSuccess() {
        realtimeServiceMock.fetchDataSingleResponse = .just(testData)
        let result = try! sut.fetchPublicDataSingle(type: [WorkoutPart].self, endpoint: .workouts)
            .toArrayAndBlocking()
        let expected: [Event<[WorkoutPart]>] = [.next(testData), .completed]

        XCTAssertEqual(result, expected)
    }
    
    func testFetchPublicDataSingleFailure() {
        let error = TestError.testError
        realtimeServiceMock.fetchDataSingleResponse = .error(error)
        let result = try! sut.fetchPublicDataSingle(type: [WorkoutPart].self, endpoint: .workouts)
            .toArrayAndBlocking()
        let expected: [Event<[WorkoutPart]>] = [.error(error)]

        XCTAssertEqual(result, expected)
    }
    
    func testFetchPersonalDataSingleFailure() {
        let error = TestError.testError
        realtimeServiceMock.fetchDataSingleResponse = .error(error)
        let result = try! sut.fetchPersonalDataSingle(type: [WorkoutPart].self, endpoint: .workouts)
            .toArrayAndBlocking()
        let expected: [Event<[WorkoutPart]>] = [.error(AuthError.unauthenticatedUser)]
        XCTAssertEqual(result, expected)
    }
    
    func testFetchPersonalDataObservableFailure() {
        realtimeServiceMock.fetchDataObservableResponse = .just(testData)
        let result = try! sut.fetchPersonalDataObservable(type: [WorkoutPart].self, endpoint: .workouts)
            .toArrayAndBlocking()
        let expected: [Event<[WorkoutPart]>] = [.error(AuthError.unauthenticatedUser)]
        XCTAssertEqual(result, expected)
    }
    
    func testDeletePersonalDataWithID() {
        let result = try! sut.deletePersonalDataWithID(endpoint: .workouts, dataID: UUID())
            .toArrayAndBlocking()
        XCTAssertEqual(result, .error(AuthError.unauthenticatedUser))
    }
    
    func testChildAddedObservable() {
        let result = try! sut.childAddedObservable(type: [WorkoutPart].self, endpoint: .workouts)
            .toArrayAndBlocking()
        let expected: [Event<[WorkoutPart]>] = [.error(AuthError.unauthenticatedUser)]

        XCTAssertEqual(result, expected)
    }
    
    func testChildRemovedObservable() {
        let result = try! sut.childRemovedObservable(type: [WorkoutPart].self, endpoint: .workouts)
            .toArrayAndBlocking()
        let expected: [Event<[WorkoutPart]>] = [.error(AuthError.unauthenticatedUser)]

        XCTAssertEqual(result, expected)
    }
}
