//
//  WorkoutPart.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 23/05/2023.
//

import Foundation

struct WorkoutPart: Codable, Equatable {
    let workoutPlanName: String
    let workoutPlanID: WorkoutPlanID
    let exercise: Exercise
    let time: Int
    let breakTime: Int
}

extension WorkoutPart {
    func generateWorkoutPartEvents() -> [WorkoutPartEvent] {
        let exerciseEvent = WorkoutPartEvent(type: .exercise, name: self.exercise.name, duration: self.time, exercise: self.exercise)
        let restEvent = WorkoutPartEvent(type: .rest, name: Localization.TrainingAssistantFlow.restEventName, duration: self.breakTime, exercise: self.exercise)
        return [exerciseEvent, restEvent]
    }
}

struct WorkoutPartEvent: Equatable {
    enum EventType {
        case exercise
        case rest
    }
    let type: EventType
    let name: String
    let duration: Int
    let exercise: Exercise
}
