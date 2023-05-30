//
//  WorkoutFinishedScreenInteractor.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 17/05/2023.
//

import RxSwift

final class WorkoutFinishedScreenInteractorImpl: WorkoutFinishedScreenInteractor {
    
    // MARK: Properties

    typealias Dependencies = HasWorkoutsHistoryService
    typealias Result = WorkoutFinishedScreenResult
    
    private let dependencies: Dependencies
    private let input: WorkoutFinishedScreenBuilderInput
    
    // MARK: Initialization

    init(dependencies: Dependencies, input: WorkoutFinishedScreenBuilderInput) {
        self.dependencies = dependencies
        self.input = input
    }
    
    // MARK: Public Implementation

    func saveWorkoutToHistory() -> RxSwift.Observable<WorkoutFinishedScreenResult> {
        return dependencies.workoutsHistoryService.saveFinishedWorkoutToHistory(finishedWorkout: input.workoutDoneModel)
            .andThen(.just(.partialState(.isWorkoutSaved(isSaved: true))))
            .catch { _ in
                    .just(.partialState(.isWorkoutSaved(isSaved: false)))
            }
    }
    
    func calculateWorkoutSummaryModels() -> Observable<WorkoutFinishedScreenResult> {
        var workoutSummaryModel: [WorkoutSummaryModel] = []
        let exerciseGroups = groupExercises()
        
        _ = exerciseGroups.map { groupedExercises in
            guard let exercise = groupedExercises.first?.exercise else { return }
            var summaryModel = WorkoutSummaryModel(exerciseName: exercise.name, exerciseType: exercise.type, setsNumber: groupedExercises.count, totalTime: nil, maxWeight: nil, maxRepetitions: nil, distance: nil)
            _ = groupedExercises.map { detailedExercise in
                switch detailedExercise.exercise.type {
                case .cardio:
                    summaryModel = handleCardioExercise(detailedExercise: detailedExercise, summaryModel: summaryModel)
                case .strength:
                    summaryModel = handlePhysicalExercise(detailedExercise: detailedExercise, summaryModel: summaryModel)
                }
            }
            workoutSummaryModel.append(summaryModel)
        }
        return .just(.partialState(.calculateWorkoutSummaryModel(workoutSummaryModel: workoutSummaryModel)))
    }
    
    // MARK: Private Implementation
    
    private func groupExercises() -> [[DetailedExercise]] {
        var exerciseGroups: [[DetailedExercise]] = []

        for detailedExercise in input.workoutDoneModel.exercisesDetails {
            let exerciseName = detailedExercise.exercise.name
            
            if let index = exerciseGroups.firstIndex(where: { $0.first?.exercise.name == exerciseName }) {
                exerciseGroups[index].append(detailedExercise)
            } else {
                exerciseGroups.append([detailedExercise])
            }
        }
        return exerciseGroups
    }
    
    private func handleCardioExercise(detailedExercise: DetailedExercise, summaryModel: WorkoutSummaryModel) -> WorkoutSummaryModel {
        var summary = summaryModel
        if let details = detailedExercise.details {
            for detail in details {
                switch detail {
                case .distance(let distance):
                    summary.distance = distance
                case .totalTime(let totalTime):
                    summary.totalTime = Int(totalTime.rounded(.towardZero))
                default:
                    break
                }
            }
        }
        return summary
    }
    
    private func handlePhysicalExercise(detailedExercise: DetailedExercise, summaryModel: WorkoutSummaryModel) -> WorkoutSummaryModel {
        var summary = summaryModel
        if let details = detailedExercise.details {
            for detail in details {
                switch detail {
                case .repetitions(let repetitions):
                    if repetitions >= summaryModel.maxRepetitions ?? 0 {
                        summary.maxRepetitions = repetitions
                    }
                case .weight(let weight):
                    if weight >= summaryModel.maxWeight ?? 0.0 {
                        summary.maxWeight = weight
                    }
                default:
                    break
                }
            }
        }
        return summary
    }
}
