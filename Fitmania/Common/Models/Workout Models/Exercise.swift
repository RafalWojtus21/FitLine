//
//  Exercise.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 23/05/2023.
//

import Foundation

struct Exercise: Codable, Equatable, Hashable {
    let id: String
    let categories: [Category]
    let name: String
    let videoID: String?
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
        case core
        case butt
        case rotators
        
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
        
        var shouldMeasureTime: Bool {
            switch self {
            case .cardio:
                return true
            default:
                return false
            }
        }
    }
    
    var type: ExerciseType {
        categories.contains(.cardio) ? .cardio : .strength
    }
    
    enum DetailsType: String, Codable, Equatable {
        case repetitions = "Repetitions"
        case weight = "Weight"
        case distance = "Distance"
    }
}

extension Exercise.ExerciseType {
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
        case weight(Float)
        case distance(Float)
        case totalTime(TimeInterval)
    }
}
