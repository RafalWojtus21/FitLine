//
//  ScheduleWorkoutScreenMiddleware.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 10/05/2023.
//

import RxSwift

final class ScheduleWorkoutScreenMiddlewareImpl: ScheduleWorkoutScreenMiddleware, ScheduleWorkoutScreenCallback {
    typealias Dependencies = HasTrainingAssistantFlowNavigation
    typealias Result = ScheduleWorkoutScreenResult
    
    private let dependencies: Dependencies
    private let chosenWorkout: WorkoutPlan
    
    private let middlewareSubject = PublishSubject<Result>()
    var middlewareObservable: Observable<Result> { return middlewareSubject }
    
    init(dependencies: Dependencies, chosenWorkout: WorkoutPlan) {
        self.dependencies = dependencies
        self.chosenWorkout = chosenWorkout
    }
    
    func process(result: Result) -> Observable<Result> {
        switch result {
        case .partialState(_): break
        case .effect(let effect):
            switch effect {
            case .startNowButtonPressed:
                dependencies.trainingAssistantFlowNavigation?.showWorkoutExerciseScreen(plan: chosenWorkout)
            case .showWorkoutPreview:
                dependencies.trainingAssistantFlowNavigation?.showWorkoutPreviewScreen(plan: chosenWorkout)
            case .workoutScheduled:
                break
            case .workoutScheduleError:
                break
            case .showDateTimePicker:
                break
            case .editWorkout:
                dependencies.trainingAssistantFlowNavigation?.editWorkoutPlan(chosenWorkout)
            }
        }
        return .just(result)
    }
}
