//
//  WorkoutsListScreenInteractor.swift
//  FitmaniaTests
//
//  Created by Rafał Wojtuś on 22/05/2023.
//

@testable import Fitmania
import XCTest
import RxSwift
import RxTest
import RxBlocking

final class WorkoutsListScreenInteractorTests: XCTestCase {
    
    struct Dependencies: WorkoutsListScreenInteractorImpl.Dependencies {
        var cloudService: CloudService { cloudServiceMock }
        let cloudServiceMock = CloudServiceMock()

        var workoutsService: WorkoutsService { workoutsServiceMock }
        let workoutsServiceMock = WorkoutsServiceMock()
    }
    
    var dependencies: Dependencies!
    var sut: WorkoutsListScreenInteractor!
    var bag: DisposeBag!
    var observer: TestableObserver<WorkoutsListScreenResult>!
    
    override func setUp() {
        dependencies = Dependencies()
        sut = WorkoutsListScreenInteractorImpl(dependencies: dependencies)
        bag = DisposeBag()
        observer = TestScheduler(initialClock: 0).createObserver(WorkoutsListScreenResult.self)
    }
    
    func testLoadTrainingPlansSuccess() {
        let plan1Name = "plan 1"
        let plan1ID = WorkoutPlanID(workoutPlanID: UUID())
        let plan1Parts: [WorkoutPart] = [WorkoutPart(workoutPlanName: plan1Name, workoutPlanID: plan1ID, exercise: Exercise(category: .cardio, name: "running"), details: WorkoutPart.Details(sets: nil, time: 3, breakTime: 3)), WorkoutPart(workoutPlanName: plan1Name, workoutPlanID: plan1ID, exercise: Exercise(category: .triceps, name: "dips"), details: WorkoutPart.Details(sets: nil, time: 33, breakTime: 33))]
        
        let plan2Name = "plan 2"
        let plan2ID = WorkoutPlanID(workoutPlanID: UUID())
        let plan2Parts: [WorkoutPart] = [WorkoutPart(workoutPlanName: plan2Name, workoutPlanID: plan2ID, exercise: Exercise(category: .chest, name: "push ups"), details: WorkoutPart.Details(sets: nil, time: 1, breakTime: 11)), WorkoutPart(workoutPlanName: plan2Name, workoutPlanID: plan2ID, exercise: Exercise(category: .legs, name: "squats"), details: WorkoutPart.Details(sets: 2, time: nil, breakTime: 22))]
        
        let workoutParts: [WorkoutPart] = plan1Parts + plan2Parts
        dependencies.workoutsServiceMock.workoutsSubject.onNext(workoutParts.sorted(by: { $0.workoutPlanName < $1.workoutPlanName }))
        
        sut.loadTrainingPlans()
            .subscribe(observer)
            .disposed(by: bag)
        
        let workoutPlans: [WorkoutPlan] = [WorkoutPlan(name: plan1Name, id: plan1ID, parts: plan1Parts), WorkoutPlan(name: plan2Name, id: plan2ID, parts: plan2Parts)]
        let result = observer.events.compactMap { $0.value.element }
        
        XCTAssertEqual(result, [.partialState(WorkoutsListScreenPartialState.updateTrainingPlans(plans: workoutPlans.sorted(by: { $0.name < $1.name })))])
    }
    
    func testLoadTrainingPlansError() {
        let plan1Name = "plan 1"
        let plan1ID = WorkoutPlanID(workoutPlanID: UUID())
        let plan1Parts: [WorkoutPart] = []
        
        let plan2Name = "plan 2"
        let plan2ID = WorkoutPlanID(workoutPlanID: UUID())
        let plan2Parts: [WorkoutPart] = []
        
        let workoutParts: [WorkoutPart] = plan1Parts + plan2Parts
        dependencies.workoutsServiceMock.workoutsSubject.onNext(workoutParts.sorted(by: { $0.workoutPlanName < $1.workoutPlanName }))
        
        sut.loadTrainingPlans()
            .subscribe(observer)
            .disposed(by: bag)
        
        let workoutPlans: [WorkoutPlan] = [WorkoutPlan(name: plan1Name, id: plan1ID, parts: plan1Parts), WorkoutPlan(name: plan2Name, id: plan2ID, parts: plan2Parts)]
        let result = observer.events.compactMap { $0.value.element }
        
        XCTAssertEqual(result, [.partialState(WorkoutsListScreenPartialState.updateTrainingPlans(plans: []))])
    }
    
    func testDeleteTrainingPlanSuccess() {
        dependencies.workoutsServiceMock.deleteWorkoutPlanResponse = .completed
        let id = WorkoutPlanID(workoutPlanID: UUID())
        
        sut.deleteTrainingPlan(id: id)
            .subscribe(observer)
            .disposed(by: bag)
        let result = observer.events.compactMap { $0.value.element }
        
        XCTAssertEqual(result, [.effect(WorkoutsListScreenEffect.workoutPlanDeleted)])
    }
    
    func testDeleteTrainingPlanFailure() {
        enum TestError: LocalizedError, Equatable {
            case testError
        }
        dependencies.workoutsServiceMock.deleteWorkoutPlanResponse = .error(TestError.testError)
        let id = WorkoutPlanID(workoutPlanID: UUID())
        
        sut.deleteTrainingPlan(id: id)
            .subscribe(observer)
            .disposed(by: bag)
        let result = observer.events.compactMap { $0.value.element }
        
        XCTAssertEqual(result, [.effect(WorkoutsListScreenEffect.somethingWentWrong)])
    }
}
