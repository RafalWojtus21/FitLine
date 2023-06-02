//
//  ScheduleWorkoutScreenInteractorTests.swift
//  FitmaniaTests
//
//  Created by Rafał Wojtuś on 02/06/2023.
//

@testable import Fitmania
import XCTest
import RxSwift
import RxTest
import RxBlocking

final class ScheduleWorkoutScreenInteractorTests: XCTestCase {
    
    struct Dependencies: ScheduleWorkoutScreenInteractorImpl.Dependencies {
    }
    
    var dependencies: Dependencies!
    var sut: ScheduleWorkoutScreenInteractor!
    var bag: DisposeBag!
    var observer: TestableObserver<ScheduleWorkoutScreenResult>!
    
    let part1Time: Int? = nil
    let part1BreakTime = 45
    let part2Time = 90
    let part2BreakTime = 45
    
    override func setUp() {
        dependencies = Dependencies()
        let planName = "Test plan"
        let planID = WorkoutPlanID(workoutPlanID: UUID())
        let plan = WorkoutPlan(name: planName, id: planID, parts: [
            WorkoutPart(workoutPlanName: planName, workoutPlanID: planID, exercise: Exercise(category: .chest, name: "chest exercise"), details: WorkoutPart.Details(sets: 4, time: part1Time, breakTime: part1BreakTime)),
            WorkoutPart(workoutPlanName: planName, workoutPlanID: planID, exercise: Exercise(category: .cardio, name: "running"), details: WorkoutPart.Details(sets: nil, time: part2Time, breakTime: part2BreakTime))
        ])
        sut = ScheduleWorkoutScreenInteractorImpl(dependencies: dependencies, chosenWorkout: plan)
        bag = DisposeBag()
        observer = TestScheduler(initialClock: 0).createObserver(ScheduleWorkoutScreenResult.self)
    }
    
    func testCalculateWorkoutDetails() {
        sut.calculateWorkoutDetails()
            .subscribe(observer)
            .disposed(by: bag)
        let result = observer.events.compactMap { $0.value.element }
        let totalTimeInSeconds = (part1Time ?? 0) + part1BreakTime + part2Time + part2BreakTime
        let totalTimeInMinutes = totalTimeInSeconds / 60
        XCTAssertEqual(result, [.partialState(.updateWorkoutInfo(totalWorkoutTimeInSeconds: totalTimeInSeconds, totalWorkoutTimeInMinutes: totalTimeInMinutes, categories: [.cardio, .chest]))])
    }
}
