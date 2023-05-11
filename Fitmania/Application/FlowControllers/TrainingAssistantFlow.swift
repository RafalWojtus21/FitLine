//
//  TrainingAssistantFlow.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 10/05/2023.
//

import UIKit

protocol HasTrainingAssistantFlowNavigation {
    var trainingAssistantFlowNavigation: TrainingAssistantFlowNavigation? { get }
}

protocol TrainingAssistantFlow {
    func startTrainingAssistantFlow(plan: WorkoutPlan)
}

protocol TrainingAssistantFlowNavigation: AnyObject {
    func showScheduleWorkoutScreen(plan: WorkoutPlan)
    func showWorkoutPreviewScreen(plan: WorkoutPlan)
}

class TrainingAssistantFlowController: TrainingAssistantFlow, TrainingAssistantFlowNavigation {
    typealias Dependencies = HasNavigation & HasAppNavigation & HasWorkoutFlowNavigation
    
    struct ExtendedDependencies: Dependencies, HasTrainingAssistantFlowNavigation {
        private let dependencies: Dependencies
        weak var appNavigation: AppNavigation?
        var navigation: Navigation { dependencies.navigation }
        weak var workoutFlowNavigation: WorkoutFlowNavigation?
        var trainingAssistantFlowNavigation: TrainingAssistantFlowNavigation?

        init(dependencies: Dependencies, trainingAssistantFlowNavigation: TrainingAssistantFlowNavigation) {
            self.dependencies = dependencies
            self.appNavigation = dependencies.appNavigation
            self.workoutFlowNavigation = dependencies.workoutFlowNavigation
            self.trainingAssistantFlowNavigation = trainingAssistantFlowNavigation
        }
    }
    
    // MARK: - Properties

    private let dependencies: Dependencies
    private lazy var extendedDependencies = ExtendedDependencies(dependencies: dependencies, trainingAssistantFlowNavigation: self)

    // MARK: - Flows
    
    // MARK: - Initialization

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    // MARK: - Builders
    
    private lazy var scheduleWorkoutScreenBuilder: ScheduleWorkoutScreenBuilder = ScheduleWorkoutScreenBuilderImpl(dependencies: extendedDependencies)
    private lazy var workoutPreviewScreenBuilder: WorkoutPreviewScreenBuilder = WorkoutPreviewScreenBuilderImpl(dependencies: extendedDependencies)
    
    // MARK: - AppNavigation
    
    func startTrainingAssistantFlow(plan: WorkoutPlan) {
        showScheduleWorkoutScreen(plan: plan)
    }
    
    func showScheduleWorkoutScreen(plan: WorkoutPlan) {
        let view = scheduleWorkoutScreenBuilder.build(with: .init(chosenWorkout: plan)).view
        dependencies.navigation.show(view: view, animated: false)
    }
    
    func showWorkoutPreviewScreen(plan: WorkoutPlan) {
        let view = workoutPreviewScreenBuilder.build(with: .init(chosenWorkout: plan)).view
        dependencies.navigation.show(view: view, animated: false)
    }
    
    func finishTrainingAssistantFlow() {
        dependencies.workoutFlowNavigation?.finishedTrainingAssistantFlow()
    }
}
