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

    func testSaveFinishedWorkoutChildAddedObservable() {
        cloudServiceMock.childAddedObservableResponse = .just(sampleWorkout)
        let bag = DisposeBag()
        let testScheduler = TestScheduler(initialClock: 0)
//        cloudServiceMock.scheduler = testScheduler
        let subject = testScheduler.createObserver([FinishedWorkout].self)
        let result = try! sut.workoutsHistoryObservable
            .subscribe(onNext: { value in
                subject.onNext(value)
            })
            .disposed(by: bag)
        
        let expected: [Event<[FinishedWorkout]>] = [.next([sampleWorkout])]
//        XCTAssertEqual(result, expected)
    }
    
    func testSaveFinishedWorkoutChildAddedObservable2() {
        let bag = DisposeBag()
        let testScheduler = TestScheduler(initialClock: 0)

        // Create a PublishSubject to simulate childAddedObservable events
        let childAddedSubject = PublishSubject<Decodable>()
        cloudServiceMock.childAddedObservableResponse = childAddedSubject

        let subject = testScheduler.createObserver([FinishedWorkout].self)
        let result = try! sut.workoutsHistoryObservable
            .subscribe(onNext: { value in
                subject.onNext(value)
            })
            .disposed(by: bag)

        // Set the scheduler property of cloudServiceMock
//        cloudServiceMock.scheduler = testScheduler

        // Trigger the event by emitting a value on the childAddedSubject
        testScheduler.scheduleAt(10) {
            childAddedSubject.onNext(self.sampleWorkout)
        }

        // Advance the scheduler to trigger the event
        testScheduler.start()

        let expected: [Recorded<Event<[FinishedWorkout]>>] = [
            .next(0, []),
            .next(10, [sampleWorkout])
        ]
        XCTAssertEqual(subject.events, expected)
    }

    
    func testSaveFinishedWorkoutChildAddedObservable3() {
        let bag = DisposeBag()
        let testScheduler = TestScheduler(initialClock: 0)
        
        let childAddedSubject = PublishSubject<Decodable>()
        cloudServiceMock.childAddedObservableResponse = childAddedSubject
        
        let observer = testScheduler.createObserver([FinishedWorkout].self)
        
        sut.workoutsHistoryObservable
            .subscribe(observer)
            .disposed(by: bag)
        
        childAddedSubject.onNext(self.sampleWorkout)
        
        let expected: [Recorded<Event<[FinishedWorkout]>>] = [
            .next(0, []),
            .next(10, [sampleWorkout])
        ]
        let result = observer.events
        XCTAssertEqual(result, expected)
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
