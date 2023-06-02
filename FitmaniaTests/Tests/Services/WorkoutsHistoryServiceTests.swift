//
//  WorkoutsHistoryServiceTests.swift
//  FitmaniaTests
//
//  Created by Rafał Wojtuś on 02/06/2023.
//

@testable import Fitmania
import XCTest
import RxSwift
import RxTest
import RxBlocking

final class WorkoutsHistoryServiceTests: XCTestCase {
    var sut: WorkoutsHistoryService!
    var cloudServiceMock: CloudServiceMock!
    
    let sampleWorkout = FinishedWorkout(workoutPlanName: "plan nmae", workoutID: WorkoutPlanID(workoutPlanID: UUID()), exercisesDetails: [DetailedExercise(exercise: Exercise(category: .chest, name: "push ups"), details: [.repetitions(12), .weight(94.5)]), DetailedExercise(exercise: Exercise(category: .cardio, name: "running"), details: [.distance(98.5), .totalTime(TimeInterval(99))])], startDate: Date(), finishDate: Date())
    override func setUp() {
        cloudServiceMock = CloudServiceMock()
        sut = WorkoutsHistoryServiceImpl(cloudService: cloudServiceMock)
    }
    
    func testSaveFinishedWorkoutToHistorySuccess() {
        cloudServiceMock.savePersonalDataWithIDResponse = .completed
        let result = try! sut.saveFinishedWorkoutToHistory(finishedWorkout: sampleWorkout)
            .toArrayAndBlocking()
        XCTAssertEqual(result, .completed)
    }
    
    func testSaveFinishedWorkoutToHistorError() {
        enum TestError: LocalizedError, Equatable {
            case testError
        }
        cloudServiceMock.savePersonalDataWithIDResponse = .error(TestError.testError)
        let result = try! sut.saveFinishedWorkoutToHistory(finishedWorkout: sampleWorkout)
            .toArrayAndBlocking()
        XCTAssertEqual(result, .error(TestError.testError))
    }
}
