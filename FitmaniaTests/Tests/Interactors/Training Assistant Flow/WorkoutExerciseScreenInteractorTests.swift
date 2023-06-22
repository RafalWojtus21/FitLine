//
//  WorkoutExerciseScreenInteractorTests.swift
//  FitmaniaTests
//
//  Created by Rafał Wojtuś on 02/06/2023.
//

@testable import Fitmania
import XCTest
import RxSwift
import RxTest
import RxBlocking

final class WorkoutExerciseScreenInteractorTests: XCTestCase {
    
    struct Dependencies: WorkoutExerciseScreenInteractorImpl.Dependencies {
    }
    
    var dependencies: Dependencies!
    var sut: WorkoutExerciseScreenInteractor!
    var bag: DisposeBag!
    var observer: TestableObserver<WorkoutExerciseScreenResult>!
    
    let strengthExerciseFirstPlanName = "Test plan"
    let strengthExerciseFirstPlanID = WorkoutPlanID(workoutPlanID: UUID())
    var strengthExerciseFirstPlan: WorkoutPlan {
        WorkoutPlan(name: strengthExerciseFirstPlanName, id: strengthExerciseFirstPlanID, parts: [
            WorkoutPart(workoutPlanName: strengthExerciseFirstPlanName, workoutPlanID: strengthExerciseFirstPlanID, exercise: Exercise(category: .chest, name: "chest exercise"), details: WorkoutPart.Details(sets: 4, time: nil, breakTime: 45)),
            WorkoutPart(workoutPlanName: strengthExerciseFirstPlanName, workoutPlanID: strengthExerciseFirstPlanID, exercise: Exercise(category: .cardio, name: "running"), details: WorkoutPart.Details(sets: nil, time: 90, breakTime: 45)),
            WorkoutPart(workoutPlanName: strengthExerciseFirstPlanName, workoutPlanID: strengthExerciseFirstPlanID, exercise: Exercise(category: .shoulders, name: "push ups"), details: WorkoutPart.Details(sets: 3, time: nil, breakTime: 22))
        ])
    }
    
    let cardioExerciseFirstPlanName = "Test plan"
    let cardioExerciseFirstPlanID = WorkoutPlanID(workoutPlanID: UUID())
    var cardioExerciseFirstPlan: WorkoutPlan {
        WorkoutPlan(name: cardioExerciseFirstPlanName, id: cardioExerciseFirstPlanID, parts: [
            WorkoutPart(workoutPlanName: cardioExerciseFirstPlanName, workoutPlanID: cardioExerciseFirstPlanID, exercise: Exercise(category: .cardio, name: "swimming"), details: WorkoutPart.Details(sets: nil, time: 2, breakTime: 3)),
            WorkoutPart(workoutPlanName: cardioExerciseFirstPlanName, workoutPlanID: cardioExerciseFirstPlanID, exercise: Exercise(category: .cardio, name: "running"), details: WorkoutPart.Details(sets: nil, time: 2, breakTime: 3)),
            WorkoutPart(workoutPlanName: cardioExerciseFirstPlanName, workoutPlanID: cardioExerciseFirstPlanID, exercise: Exercise(category: .cardio, name: "joga"), details: WorkoutPart.Details(sets: nil, time: 2, breakTime: 3))
        ])
    }
    
    var workoutEvents: [WorkoutPartEvent] {
        strengthExerciseFirstPlan.parts.flatMap { $0.generateWorkoutPartEvents() }
    }
    
    override func setUp() {
        dependencies = Dependencies()
        
        sut = WorkoutExerciseScreenInteractorImpl(dependencies: dependencies!, workoutPlan: strengthExerciseFirstPlan)
        bag = DisposeBag()
        observer = TestScheduler(initialClock: 0).createObserver(WorkoutExerciseScreenResult.self)
    }
    
    func testLoadEvents() {
        sut.loadEvents()
            .subscribe(observer)
            .disposed(by: bag)
        let result = observer.events.compactMap { $0.value.element }
        XCTAssertEqual(result, [.partialState(.loadWorkoutEvents(workoutEvents: workoutEvents))])
    }
    
    func testGetCurrentExercisePhysical() {
        sut.getCurrentExercise()
            .subscribe(observer)
            .disposed(by: bag)
        let result = observer.events.compactMap { $0.value.element }
        XCTAssertEqual(result, [.partialState(.updateAvailableDetailsTypes(detailsTypes: [.weight, .repetitions]))])
    }
    
    func testSaveDetailsOfCurrentExercise() {
        let weight = "30.5"
        let repetitions = "12"
        sut.saveDetailOfCurrentExercise(details: [weight, repetitions])
            .subscribe(observer)
            .disposed(by: bag)
        let result = observer.events.compactMap { $0.value.element }
        XCTAssertEqual(result, [.partialState(.idle)])
    }
    
    func testSaveDetailsOfCurrentExerciseRestRepetitionsAndWeightDetails() {
        let triggerObserver = TestScheduler(initialClock: 0).createObserver(WorkoutExerciseScreenResult.self)
        
        sut.observeForExercises()
            .subscribe(triggerObserver)
            .disposed(by: bag)
        
        sut.triggerFirstExercise()
            .subscribe(triggerObserver)
            .disposed(by: bag)
        
        sut.triggerNextExercise()
            .subscribe(triggerObserver)
            .disposed(by: bag)
        
        let weight = "30.5"
        let repetitions = "12"
        
        sut.saveDetailOfCurrentExercise(details: [weight, repetitions])
            .subscribe(observer)
            .disposed(by: bag)
        
        let result = observer.events.compactMap { $0.value.element }

        XCTAssertEqual(result, [.partialState(.idle)])
    }
    
    func testSaveDetailsOfCurrentExerciseRestDistanceDetails() {
        let triggerObserver = TestScheduler(initialClock: 0).createObserver(WorkoutExerciseScreenResult.self)
        let distance = "120.5"

        sut = WorkoutExerciseScreenInteractorImpl(dependencies: dependencies!, workoutPlan: cardioExerciseFirstPlan)
        
        sut.observeForExercises()
            .subscribe(triggerObserver)
            .disposed(by: bag)
        
        sut.triggerFirstExercise()
            .subscribe(triggerObserver)
            .disposed(by: bag)
        
        sut.triggerNextExercise()
            .subscribe(triggerObserver)
            .disposed(by: bag)
        
        sut.saveDetailOfCurrentExercise(details: [distance])
            .subscribe(observer)
            .disposed(by: bag)
        
        let result = observer.events.compactMap { $0.value.element }

        XCTAssertEqual(result, [.partialState(.idle)])
    }

    
    func testObserveForExercisesInitialPhysicalExercise() {
        sut.observeForExercises()
            .subscribe(observer)
            .disposed(by: bag)
        
        let triggerObserver = TestScheduler(initialClock: 0).createObserver(WorkoutExerciseScreenResult.self)
        sut.triggerFirstExercise()
            .subscribe(triggerObserver)
            .disposed(by: bag)
        
        let triggerResult = triggerObserver.events.compactMap { $0.value.element }
        XCTAssertEqual(triggerResult, [.partialState(.idle)])
        
        let result = observer.events.compactMap { $0.value.element }
        let expected: [WorkoutExerciseScreenResult] = [.partialState(.updateIntervalState(intervalState: .running)),
                                                       .partialState(.updateCurrentEventIndex(currentEventIndex: 0)),                                                       .partialState(.shouldShowTimer(isTimerVisible: false)),
                                                       .partialState(.triggerAnimation),
                                                       .partialState(.updateAvailableDetailsTypes(detailsTypes: [])),
        ]
        XCTAssertEqual(result, expected)
    }
    
    func testObserveForExercisesNextRestType() {
        sut.observeForExercises()
            .subscribe(observer)
            .disposed(by: bag)
        
        let triggerObserver = TestScheduler(initialClock: 0).createObserver(WorkoutExerciseScreenResult.self)
        sut.triggerNextExercise()
            .subscribe(triggerObserver)
            .disposed(by: bag)
        
        let triggerResult = triggerObserver.events.compactMap { $0.value.element }
        XCTAssertEqual(triggerResult, [.partialState(.updateIntervalState(intervalState: .running))])
        
        let result = observer.events.compactMap { $0.value.element }
        let expected: [WorkoutExerciseScreenResult] = [
            .partialState(.shouldShowTimer(isTimerVisible: true)),
            .partialState(.updateAvailableDetailsTypes(detailsTypes: [.weight, .repetitions])),
            .partialState(.setAnimationDuration(duration: 45)),
            .partialState(.updateCurrentEventIndex(currentEventIndex: 1))
        ]
        XCTAssertEqual(result, expected)
    }
    
    func testGetCurrentExercise() {
        let triggerObserver = TestScheduler(initialClock: 0).createObserver(WorkoutExerciseScreenResult.self)
        sut.triggerFirstExercise()
            .subscribe(triggerObserver)
            .disposed(by: bag)
        
        sut.getCurrentExercise()
            .subscribe(observer)
            .disposed(by: bag)
        
        let result = observer.events.compactMap { $0.value.element }
        let expected: [WorkoutExerciseScreenResult] = [
            .partialState(.updateAvailableDetailsTypes(detailsTypes: [.weight, .repetitions]))
        ]
        XCTAssertEqual(result, expected)
    }

    func testTriggerFirstExercise() {
        sut.triggerFirstExercise()
            .subscribe(observer)
            .disposed(by: bag)
        
        let result = observer.events.compactMap { $0.value.element }
        
        XCTAssertEqual(result, [.partialState(.idle)])
    }
    
    func testTriggerNextExercisePhysical() {
        sut.triggerNextExercise()
            .subscribe(observer)
            .disposed(by: bag)
        
        let result = observer.events.compactMap { $0.value.element }
        
        XCTAssertEqual(result, [.partialState(.updateIntervalState(intervalState: .running))])
    }
    
    func testTriggerNextExerciseCardio() {
        let triggerObserver = TestScheduler(initialClock: 0).createObserver(WorkoutExerciseScreenResult.self)

        sut = WorkoutExerciseScreenInteractorImpl(dependencies: dependencies!, workoutPlan: cardioExerciseFirstPlan)
        
        sut.observeForExercises()
            .subscribe(triggerObserver)
            .disposed(by: bag)
        
        sut.triggerFirstExercise()
            .subscribe(triggerObserver)
            .disposed(by: bag)
        
        sut.triggerNextExercise()
            .subscribe(triggerObserver)
            .disposed(by: bag)
        
        sut.triggerNextExercise()
            .subscribe(observer)
            .disposed(by: bag)
        
        let result = observer.events.compactMap { $0.value.element }
        
        XCTAssertEqual(result, [.partialState(.updateIntervalState(intervalState: .running))])
    }
    
    func testHandleLastEvent() {
        let newPlanName = "Test plan"
        let newPlanID = WorkoutPlanID(workoutPlanID: UUID())
        let exercise = Exercise(category: .cardio, name: "running")
        var newPlan: WorkoutPlan {
            WorkoutPlan(name: newPlanName, id: newPlanID, parts: [
                WorkoutPart(workoutPlanName: newPlanName, workoutPlanID: newPlanID, exercise: exercise, details: WorkoutPart.Details(sets: nil, time: 90, breakTime: 45))
            ])
        }
        
        sut = WorkoutExerciseScreenInteractorImpl(dependencies: dependencies!, workoutPlan: newPlan)
        
        sut.observeForExercises()
            .subscribe(observer)
            .disposed(by: bag)
        
        sut.triggerFirstExercise()
            .subscribe(observer)
            .disposed(by: bag)
                
        sut.triggerNextExercise()
            .subscribe(observer)
            .disposed(by: bag)
        
        sut.triggerNextExercise()
            .subscribe(observer)
            .disposed(by: bag)
        
        let result = observer.events.compactMap { $0.value.element }
        
        XCTAssertTrue(result.contains { result in
            if case .effect(let effect) = result {
                if case .workoutFinished(let finishedWorkout) = effect {
                    return finishedWorkout.workoutPlanName == newPlanName && finishedWorkout.exercisesDetails.contains { detailedExercise in
                        detailedExercise.exercise == exercise
                    }
                }
            }
            return false
        })
    }
    
    func testSetTimerSuccess() {
        let triggerObserver = TestScheduler(initialClock: 0).createObserver(WorkoutExerciseScreenResult.self)
        
        sut = WorkoutExerciseScreenInteractorImpl(dependencies: dependencies!, workoutPlan: cardioExerciseFirstPlan)

        sut.observeForExercises()
            .subscribe(triggerObserver)
            .disposed(by: bag)
        
        sut.triggerFirstExercise()
            .subscribe(triggerObserver)
            .disposed(by: bag)
        
        sut.triggerNextExercise()
            .subscribe(triggerObserver)
            .disposed(by: bag)
        
        let expectation = XCTestExpectation(description: "Time left should be equal to 0 and interval state should be .finished")
        
        let disposable = sut.setTimer()
            .subscribe(onNext: { result in
                if case .partialState(let state) = result {
                    if case .updateCurrentTime(let intervalState, let timeLeft) = state {
                        if timeLeft <= 0 && intervalState == .finished {
                            expectation.fulfill()
                        }
                    }
                }
            })
        wait(for: [expectation], timeout: 10)
        disposable.dispose()
    }
    
    func testPauseTimerWhenTimerRunning() {        
        sut = WorkoutExerciseScreenInteractorImpl(dependencies: dependencies!, workoutPlan: cardioExerciseFirstPlan)
        
        let sideObserver = TestScheduler(initialClock: 0).createObserver(WorkoutExerciseScreenResult.self)
        sut.setTimer()
            .subscribe(sideObserver)
            .disposed(by: bag)
        
        sut.pauseTimer()
            .subscribe(observer)
            .disposed(by: bag)
        
        let result = observer.events.compactMap { $0.value.element }
        
        XCTAssertEqual(result, [.partialState(.updateIntervalState(intervalState: .paused))])
    }
    
    func testPauseTimerWhenTimerNotRunning() {
        sut.pauseTimer()
            .subscribe(observer)
            .disposed(by: bag)
        
        let result = observer.events.compactMap { $0.value.element }
        
        XCTAssertEqual(result, [.partialState(.updateIntervalState(intervalState: .paused))])
    }
    
    func testResumeTimerWhenTimerRunning() {
        let sideObserver = TestScheduler(initialClock: 0).createObserver(WorkoutExerciseScreenResult.self)
        
        sut = WorkoutExerciseScreenInteractorImpl(dependencies: dependencies!, workoutPlan: cardioExerciseFirstPlan)

        sut.setTimer()
            .subscribe(sideObserver)
            .disposed(by: bag)
        
        sut.pauseTimer()
            .subscribe(sideObserver)
            .disposed(by: bag)
        
        sut.resumeTimer()
            .subscribe(observer)
            .disposed(by: bag)
        
        let result = observer.events.compactMap { $0.value.element }
        
        XCTAssertEqual(result, [.partialState(.updateIntervalState(intervalState: .running))])
    }
    
    func testResumeTimerWhenTimerPaused() {
        let sideObserver = TestScheduler(initialClock: 0).createObserver(WorkoutExerciseScreenResult.self)
        
        sut = WorkoutExerciseScreenInteractorImpl(dependencies: dependencies!, workoutPlan: cardioExerciseFirstPlan)

        sut.setTimer()
            .subscribe(sideObserver)
            .disposed(by: bag)
        
        sut.pauseTimer()
            .subscribe(sideObserver)
            .disposed(by: bag)
        
        sut.resumeTimer()
            .subscribe(observer)
            .disposed(by: bag)
        
        let result = observer.events.compactMap { $0.value.element }
        
        XCTAssertEqual(result, [.partialState(.updateIntervalState(intervalState: .running))])
    }
    
}
