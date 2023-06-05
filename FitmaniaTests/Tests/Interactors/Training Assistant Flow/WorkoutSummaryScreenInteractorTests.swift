//
//  WorkoutSummaryScreenInteractor.swift
//  FitmaniaTests
//
//  Created by Rafał Wojtuś on 05/06/2023.
//

@testable import Fitmania
import XCTest
import RxSwift
import RxTest
import RxBlocking

final class WorkoutSummaryScreenInteractorTests: XCTestCase {
    
    struct Dependencies: WorkoutSummaryScreenInteractorImpl.Dependencies {
        let workoutsHistoryServiceMock = WorkoutsHistoryServiceMock()
        var workoutsHistoryService: WorkoutsHistoryService { workoutsHistoryServiceMock }
    }
    
    var dependencies: Dependencies!
    var sut: WorkoutSummaryScreenInteractor!
    var bag: DisposeBag!
    var observer: TestableObserver<WorkoutSummaryScreenResult>!
    
    let exercise1Name = "push ups"
    let exercise1Category: Exercise.Category = .shoulders
    let exercise1Details: [DetailedExercise.Details] = [.weight(80.5), .repetitions(12)]
    
    let exercise2Name = "running"
    let exercise2Category: Exercise.Category = .cardio
    let exercise2Details: [DetailedExercise.Details] = [.distance(100.6), .totalTime(992)]
    
    let planName = "Test plan"
    let planID = WorkoutPlanID(workoutPlanID: UUID())

    var workout: FinishedWorkout {
        let details: [DetailedExercise] = [
            DetailedExercise(exercise: Exercise(category: exercise1Category, name: exercise1Name), details: exercise1Details),
            DetailedExercise(exercise: Exercise(category: exercise2Category, name: exercise2Name), details: exercise2Details),
        ]
        let workout = FinishedWorkout(workoutPlanName: planName, workoutID: planID, exercisesDetails: details, startDate: Date(), finishDate: Date())
        return workout
    }
    
    override func setUp() {
        dependencies = Dependencies()
        sut = WorkoutSummaryScreenInteractorImpl(dependencies: dependencies, input: WorkoutSummaryScreenBuilderInput(workoutDoneModel: workout, shouldSaveWorkout: false))
        bag = DisposeBag()
        observer = TestScheduler(initialClock: 0).createObserver(WorkoutSummaryScreenResult.self)
    }
    
    func testSaveWorkoutToHistory() {
        sut.saveWorkoutToHistory()
            .subscribe(observer)
            .disposed(by: bag)
        
        let result = observer.events.compactMap { $0.value.element }
        
        XCTAssertEqual(result, [.partialState(.isWorkoutSaved(savingStatus: .notNeeded))])
    }
    
    func testCalculateWorkoutSummaryModels() {
        sut.calculateWorkoutSummaryModels()
            .subscribe(observer)
            .disposed(by: bag)
        
        let result = observer.events.compactMap { $0.value.element }
        var workoutSummaryModel: [WorkoutSummaryModel] = []
        var summary1 = WorkoutSummaryModel(exerciseName: exercise1Name, exerciseType: .strength, setsNumber: 1)
        summary1.maxRepetitions = 12
        summary1.maxWeight = 80.5
        workoutSummaryModel.append(summary1)
        var summary2 = WorkoutSummaryModel(exerciseName: exercise2Name, exerciseType: .cardio, setsNumber: 1)
        summary2.distance = 100.6
        summary2.totalTime = 992
        workoutSummaryModel.append(summary2)
        let expected: [WorkoutSummaryScreenResult] =
        [.partialState(.calculateWorkoutSummaryModel(workoutSummaryModel: workoutSummaryModel))]
        XCTAssertEqual(result, expected)
    }
}
