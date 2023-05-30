//
//  Exercise.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 23/05/2023.
//

import Foundation

struct Exercise: Codable, Equatable, Hashable {
    let category: Category
    let name: String
}

extension Exercise {
    enum Category: String, CaseIterable, Codable {
        case cardio
        case legs
        case biceps
        case triceps
        case chest
        case shoulders
        case back
        
        var shouldMeasureTime: Bool {
            switch self {
            case .cardio:
                return true
            default:
                return false
            }
        }
        
        var isTimeVisible: Bool {
            switch self {
            case .cardio:
                return true
            default:
                return false
            }
        }
        
        var areSetsVisible: Bool {
            return !isTimeVisible
        }
    }
    
    enum ExerciseType {
        case strength
        case cardio
    }
    
    var type: ExerciseType {
        switch category {
        case .cardio:
            return .cardio
        default:
            return .strength
        }
    }
    
    enum DetailsType: String, Codable, Equatable {
        case repetitions = "Repetitions"
        case weight = "Weight"
        case distance = "Distance"
    }
}

extension Exercise.Category {
    func generatePossibleDetails() -> [Exercise.DetailsType] {
        switch self {
        case .cardio:
            return [.distance]
        default:
            return [.weight, .repetitions]
        }
    }
}

struct DetailedExercise: Codable, Equatable, Hashable {
    let exercise: Exercise
    let details: [Details]?
    
    enum Details: Codable, Equatable, Hashable {
        case repetitions(Int)
        case weight(Double)
        case distance(Double)
        case totalTime(TimeInterval)
    }
}
