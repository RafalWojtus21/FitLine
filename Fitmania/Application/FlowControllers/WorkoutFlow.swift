//
//  HomeFlow.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 19/04/2023.
//

import UIKit

protocol HasWorkoutFlowNavigation {
    var workoutFlowNavigation: WorkoutFlowNavigation? { get }
}

protocol WorkoutFlow {
    func startWorkoutFlow() -> BaseView
    func startCreateWorkoutFlow(trainingName: String)
}

protocol WorkoutFlowNavigation: AnyObject {
    func showWorkoutsListScreen()
    func finishedCreateWorkoutFlow()
}

class WorkoutFlowController: WorkoutFlow, WorkoutFlowNavigation {
    typealias Dependencies = HasNavigation & HasAppNavigation & HasMainFlowNavigation
    
    struct ExtendedDependencies: Dependencies, HasWorkoutFlowNavigation {
        private let dependencies: Dependencies
        weak var appNavigation: AppNavigation?
        weak var mainFlowNavigation: MainFlowNavigation?
        var navigation: Navigation { dependencies.navigation }
        var workoutFlowNavigation: WorkoutFlowNavigation?

        init(dependencies: Dependencies, workoutFlowNavigation: WorkoutFlowNavigation) {
            self.dependencies = dependencies
            self.appNavigation = dependencies.appNavigation
            self.mainFlowNavigation = dependencies.mainFlowNavigation
            self.workoutFlowNavigation = workoutFlowNavigation
        }
    }
    
    // MARK: - Properties

    private let dependencies: Dependencies
    private lazy var extendedDependencies = ExtendedDependencies(dependencies: dependencies, workoutFlowNavigation: self)

    // MARK: - Flows
    
    private var createWorkoutFlowController: CreateWorkoutFlow?

    // MARK: - Initialization

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    // MARK: - Builders
    
    private lazy var homeScreenBuilder: HomeScreenBuilder = HomeScreenBuilderImpl(dependencies: extendedDependencies)

    // MARK: - AppNavigation
    
    func startWorkoutFlow() -> BaseView {
        homeScreenBuilder.build(with: .init()).view
    }
    
    func showWorkoutsListScreen() {
    }
    
    func startCreateWorkoutFlow(trainingName: String) {
        createWorkoutFlowController = CreateWorkoutFlowController(dependencies: extendedDependencies)
        createWorkoutFlowController?.startCreateWorkoutFlow(trainingName: trainingName)
    }
    
    func finishedCreateWorkoutFlow() {
        createWorkoutFlowController = nil 
    }
}
