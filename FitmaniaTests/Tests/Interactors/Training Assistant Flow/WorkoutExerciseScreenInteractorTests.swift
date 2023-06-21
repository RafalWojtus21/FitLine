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
    
    let planName = "Test plan"
    let planID = WorkoutPlanID(workoutPlanID: UUID())
    var plan: WorkoutPlan {
        WorkoutPlan(name: planName, id: planID, parts: [
            WorkoutPart(workoutPlanName: planName, workoutPlanID: planID, exercise: Exercise(category: .chest, name: "chest exercise"), details: WorkoutPart.Details(sets: 4, time: nil, breakTime: 45)),
            WorkoutPart(workoutPlanName: planName, workoutPlanID: planID, exercise: Exercise(category: .cardio, name: "running"), details: WorkoutPart.Details(sets: nil, time: 90, breakTime: 45)),
            WorkoutPart(workoutPlanName: planName, workoutPlanID: planID, exercise: Exercise(category: .shoulders, name: "push ups"), details: WorkoutPart.Details(sets: 3, time: nil, breakTime: 22))
        ])
    }
    
    var workoutEvents: [WorkoutPartEvent] {
        plan.parts.flatMap { $0.generateWorkoutPartEvents() }
    }
    
    override func setUp() {
        dependencies = Dependencies()
        
        sut = WorkoutExerciseScreenInteractorImpl(dependencies: dependencies!, workoutPlan: plan)
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
        
        let planName = "Test plan"
        let planID = WorkoutPlanID(workoutPlanID: UUID())
        
        var plan: WorkoutPlan {
            WorkoutPlan(name: planName, id: planID, parts: [
                WorkoutPart(workoutPlanName: planName, workoutPlanID: planID, exercise: Exercise(category: .cardio, name: "running"), details: WorkoutPart.Details(sets: nil, time: 90, breakTime: 45)),
                WorkoutPart(workoutPlanName: planName, workoutPlanID: planID, exercise: Exercise(category: .chest, name: "chest exercise"), details: WorkoutPart.Details(sets: 4, time: nil, breakTime: 45)),
                WorkoutPart(workoutPlanName: planName, workoutPlanID: planID, exercise: Exercise(category: .shoulders, name: "push ups"), details: WorkoutPart.Details(sets: 3, time: nil, breakTime: 22))
            ])
        }
        
        sut = WorkoutExerciseScreenInteractorImpl(dependencies: dependencies!, workoutPlan: plan)
        
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


        let distance = "120.5"
        
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

        let planName = "Test plan"
        let planID = WorkoutPlanID(workoutPlanID: UUID())
        
        var plan: WorkoutPlan {
            WorkoutPlan(name: planName, id: planID, parts: [
                WorkoutPart(workoutPlanName: planName, workoutPlanID: planID, exercise: Exercise(category: .cardio, name: "running"), details: WorkoutPart.Details(sets: nil, time: 90, breakTime: 45)),
                WorkoutPart(workoutPlanName: planName, workoutPlanID: planID, exercise: Exercise(category: .cardio, name: "swimming"), details: WorkoutPart.Details(sets: 4, time: 12, breakTime: 45)),
                WorkoutPart(workoutPlanName: planName, workoutPlanID: planID, exercise: Exercise(category: .shoulders, name: "yoga"), details: WorkoutPart.Details(sets: 3, time: 24, breakTime: 22))
            ])
        }
        
        sut = WorkoutExerciseScreenInteractorImpl(dependencies: dependencies!, workoutPlan: plan)
        
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
        sut.triggerNextExercise()
            .subscribe(triggerObserver)
            .disposed(by: bag)
        
        sut.setTimer()
            .subscribe(observer)
            .disposed(by: bag)
        
        let result = observer.events.compactMap { $0.value.element }
        
        XCTAssertEqual(result, [])
    }
    
    func testSetTimerEventDurationNil() {
        let triggerObserver = TestScheduler(initialClock: 0).createObserver(WorkoutExerciseScreenResult.self)

        let planName = "Test plan"
        let planID = WorkoutPlanID(workoutPlanID: UUID())
        var plan: WorkoutPlan {
            WorkoutPlan(name: planName, id: planID, parts: [
                WorkoutPart(workoutPlanName: planName, workoutPlanID: planID, exercise: Exercise(category: .cardio, name: "swimming"), details: WorkoutPart.Details(sets: nil, time: 12, breakTime: 45)),
                WorkoutPart(workoutPlanName: planName, workoutPlanID: planID, exercise: Exercise(category: .cardio, name: "running"), details: WorkoutPart.Details(sets: nil, time: 25, breakTime: 45)),
                WorkoutPart(workoutPlanName: planName, workoutPlanID: planID, exercise: Exercise(category: .cardio, name: "joga"), details: WorkoutPart.Details(sets: nil, time: 12, breakTime: 22))
            ])
        }
        
        sut = WorkoutExerciseScreenInteractorImpl(dependencies: dependencies!, workoutPlan: plan)
        
        sut.observeForExercises()
            .subscribe(triggerObserver)
            .disposed(by: bag)
        
        sut.triggerFirstExercise()
            .subscribe(triggerObserver)
            .disposed(by: bag)
        
        sut.setTimer()
            .subscribe(observer)
            .disposed(by: bag)
        
        let triggerResult = triggerObserver.events.compactMap { $0.value.element }
        let result = observer.events.compactMap { $0.value.element }
        
        print("Trigger: \(triggerResult)")
        print("Result: \(result)")
        
        // MARK: To do
    }
    
    func testPauseTimerWhenTimerRunning() {
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
        sut.resumeTimer()
            .subscribe(observer)
            .disposed(by: bag)
        
        let result = observer.events.compactMap { $0.value.element }
        
        XCTAssertEqual(result, [.partialState(.updateIntervalState(intervalState: .running))])
    }
    
    func testResumeTimerWhenTimerPaused() {
        let sideObserver = TestScheduler(initialClock: 0).createObserver(WorkoutExerciseScreenResult.self)
        
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
