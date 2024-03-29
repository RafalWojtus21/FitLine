//
//  WorkoutExerciseScreenMiddleware.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 11/05/2023.
//

import RxSwift
import Foundation

final class WorkoutExerciseScreenMiddlewareImpl: WorkoutExerciseScreenMiddleware, WorkoutExerciseScreenCallback {
    typealias Dependencies = HasTrainingAssistantFlowNavigation
    typealias Result = WorkoutExerciseScreenResult
    
    private let dependencies: Dependencies

    private let middlewareSubject = PublishSubject<Result>()
    var middlewareObservable: Observable<Result> { return middlewareSubject }
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    func process(result: Result) -> Observable<Result> {
        switch result {
        case .partialState(_): break
        case .effect(let effect):
            switch effect {
            case .workoutFinished(finishedWorkout: let finishedWorkout):
                dependencies.trainingAssistantFlowNavigation?.showWorkoutSummaryScreen(workoutDoneModel: finishedWorkout, shouldSaveWorkout: true)
            case .showYoutubePreview(let videoID):
                dependencies.trainingAssistantFlowNavigation?.showYoutubePreview(videoID: videoID)
            default:
                break
            }
        }
        return .just(result)
    }
}
