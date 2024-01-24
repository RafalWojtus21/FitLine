//
//  WorkoutPart.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 23/05/2023.
//

import Foundation

struct WorkoutPart: Codable, Equatable, Hashable {
    var id = UUID()
    let workoutPlanName: String
    var workoutPlanID: WorkoutPlanID
    let exercise: Exercise
    let details: Details
    
    struct Details: Codable, Equatable, Hashable {
        let sets: Int?
        let time: Int?
        let breakTime: Int
    }
}

extension WorkoutPart {
    
    init(workoutPlanName: String, workoutPlanID: WorkoutPlanID, exercise: Exercise, details: Details, id: UUID) {
        self.id = id
        self.workoutPlanName = workoutPlanName
        self.workoutPlanID = workoutPlanID
        self.exercise = exercise
        self.details = details
    }
    
    func generateWorkoutPartEvents() -> [WorkoutPartEvent] {
        var events: [WorkoutPartEvent] = []
        let exerciseEvent = WorkoutPartEvent(type: .exercise, name: exercise.name, duration: details.time, exercise: exercise)
        let restEvent = WorkoutPartEvent(type: .rest, name: Localization.TrainingAssistantFlow.restEventName, duration: details.breakTime, exercise: exercise)
        
        if let sets = details.sets, sets > 0 {
            for _ in 1 ... sets {
                events.append(exerciseEvent)
                events.append(restEvent)
            }
        } else {
            events = [exerciseEvent, restEvent]
        }
        return events
    }
}

struct WorkoutPartEvent: Equatable {
    enum EventType {
        case exercise
        case rest
    }
    let type: EventType
    let name: String
    let duration: Int?
    let exercise: Exercise
}
