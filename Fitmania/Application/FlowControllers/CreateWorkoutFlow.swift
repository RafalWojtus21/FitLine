//
//  CreateWorkoutFlow.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 26/04/2023.
//

import UIKit

protocol HasCreateWorkoutFlow {
    var createWorkoutFlowNavigation: CreateWorkoutFlowNavigation? { get }
}

protocol CreateWorkoutFlow {
    func startCreateWorkoutFlow(trainingName: String)
}

protocol CreateWorkoutFlowNavigation: AnyObject {
}

class CreateWorkoutFlowController: CreateWorkoutFlow, CreateWorkoutFlowNavigation {
    typealias Dependencies = HasNavigation & HasWorkoutFlowNavigation
    
    struct ExtendedDependencies: Dependencies, HasCreateWorkoutFlow, HasExercisesDataStore & HasValidationService {
        private let dependencies: Dependencies
        weak var workoutFlowNavigation: WorkoutFlowNavigation?
        var navigation: Navigation { dependencies.navigation }
        weak var createWorkoutFlowNavigation: CreateWorkoutFlowNavigation?
        
        let exercisesDataStore: ExercisesDataStore
        let validationService: ValidationService

        init(dependencies: Dependencies, createWorkoutFlowNavigation: CreateWorkoutFlowNavigation) {
            self.dependencies = dependencies
            self.workoutFlowNavigation = dependencies.workoutFlowNavigation
            self.createWorkoutFlowNavigation = createWorkoutFlowNavigation
            self.exercisesDataStore = ExercisesDataStoreImpl()
            self.validationService = ValidationServiceImpl()
        }
    }
    
    // MARK: - Properties
    
    private let dependencies: Dependencies
    private lazy var extendedDependencies = ExtendedDependencies(dependencies: dependencies, createWorkoutFlowNavigation: self)
    
    // MARK: - Initialization
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    // MARK: - Builders
    
    // MARK: - AppNavigation
    
    func startCreateWorkoutFlow(trainingName: String) {
    }
    
    func finishCreateWorkoutFlow() {
        dependencies.workoutFlowNavigation?.finishedCreateWorkoutFlow()
    }
}
