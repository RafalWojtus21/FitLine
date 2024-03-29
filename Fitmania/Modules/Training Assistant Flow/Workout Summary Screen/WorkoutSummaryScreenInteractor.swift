//
//  WorkoutFinishedScreenInteractor.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 17/05/2023.
//

import RxSwift

final class WorkoutSummaryScreenInteractorImpl: WorkoutSummaryScreenInteractor {
    
    // MARK: Properties

    typealias Dependencies = HasWorkoutsHistoryService
    typealias Result = WorkoutSummaryScreenResult
    
    private let dependencies: Dependencies
    private let input: WorkoutSummaryScreenBuilderInput
    
    // MARK: Initialization

    init(dependencies: Dependencies, input: WorkoutSummaryScreenBuilderInput) {
        self.dependencies = dependencies
        self.input = input
    }
    
    // MARK: Public Implementation

    func saveWorkoutToHistory() -> RxSwift.Observable<WorkoutSummaryScreenResult> {
        switch input.shouldSaveWorkout {
        case true:
            return dependencies.workoutsHistoryService.saveFinishedWorkoutToHistory(finishedWorkout: input.workoutDoneModel)
                .andThen(.just(.partialState(.isWorkoutSaved(savingStatus: .saved))))
                .catch { _ in
                        .just(.partialState(.isWorkoutSaved(savingStatus: .notSaved)))
                }
        case false:
            return .just(.partialState(.isWorkoutSaved(savingStatus: .notNeeded)))
        }
    }
    
    func calculateWorkoutSummaryModels() -> Observable<WorkoutSummaryScreenResult> {
        var workoutSummaryModel: [WorkoutSummaryModel] = []
        let exerciseGroups = groupExercises()
        
        _ = exerciseGroups.map { groupedExercises in
            guard let exercise = groupedExercises.first?.exercise else { return }
            var summaryModel = WorkoutSummaryModel(exerciseName: exercise.name, exerciseType: exercise.type, setsNumber: groupedExercises.count, totalTime: nil, weightReps: [], distance: nil)
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
            var finalWeight: Float?
            var finalRepetitions: Int?
            for detail in details {
                switch detail {
                case .repetitions(let repetitions):
                    finalRepetitions = repetitions
                case .weight(let weight):
                    finalWeight = weight
                default:
                    break
                }
            }
            summary.weightReps.append(.init(weight: finalWeight, repetitions: finalRepetitions))
        }
        return summary
    }
}
