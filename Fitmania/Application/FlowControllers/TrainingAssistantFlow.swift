//
//  TrainingAssistantFlow.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 10/05/2023.
//

import UIKit
import FirebaseAuth

protocol HasTrainingAssistantFlowNavigation {
    var trainingAssistantFlowNavigation: TrainingAssistantFlowNavigation? { get }
}

protocol TrainingAssistantFlow {
    func startTrainingAssistantFlow(plan: WorkoutPlan)
}

protocol TrainingAssistantFlowNavigation: AnyObject {
    func showScheduleWorkoutScreen(plan: WorkoutPlan)
    func showWorkoutPreviewScreen(plan: WorkoutPlan)
    func showWorkoutExerciseScreen(plan: WorkoutPlan)
    func showWorkoutFinishedScreen(workoutDoneModel: FinishedWorkout)
    func finishTrainingAssistantFlow() 
}

class TrainingAssistantFlowController: TrainingAssistantFlow, TrainingAssistantFlowNavigation {
    typealias Dependencies = HasNavigation & HasAppNavigation & HasWorkoutFlowNavigation
    
    struct ExtendedDependencies: Dependencies, HasTrainingAssistantFlowNavigation, HasWorkoutsHistoryService, HasCloudService, HasRealtimeDatabaseService, HasAuthManager {
        private let dependencies: Dependencies
        weak var appNavigation: AppNavigation?
        var navigation: Navigation { dependencies.navigation }
        weak var workoutFlowNavigation: WorkoutFlowNavigation?
        var trainingAssistantFlowNavigation: TrainingAssistantFlowNavigation?

        let workoutsHistoryService: WorkoutsHistoryService
        let cloudService: CloudService
        let realtimeDatabaseService: RealtimeDatabaseService
        let authManager: AuthManager
        
        init(dependencies: Dependencies, trainingAssistantFlowNavigation: TrainingAssistantFlowNavigation) {
            self.dependencies = dependencies
            self.appNavigation = dependencies.appNavigation
            self.workoutFlowNavigation = dependencies.workoutFlowNavigation
            self.trainingAssistantFlowNavigation = trainingAssistantFlowNavigation
            self.realtimeDatabaseService = RealtimeDatabaseServiceImpl()
            self.authManager = AuthManagerImpl(auth: Auth.auth())
            self.cloudService = CloudServiceImpl(authManager: authManager, realtimeService: realtimeDatabaseService)
            self.workoutsHistoryService = WorkoutsHistoryServiceImpl(cloudService: cloudService)
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
    private lazy var workoutExerciseScreenBuilder: WorkoutExerciseScreenBuilder = WorkoutExerciseScreenBuilderImpl(dependencies: extendedDependencies)
    private lazy var workoutFinishedScreenBuilder: WorkoutFinishedScreenBuilder = WorkoutFinishedScreenBuilderImpl(dependencies: extendedDependencies)
    
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
    
    func showWorkoutExerciseScreen(plan: WorkoutPlan) {
        let view = workoutExerciseScreenBuilder.build(with: .init(chosenPlan: plan)).view
        dependencies.navigation.show(view: view, animated: false)
    }
    
    func showWorkoutFinishedScreen(workoutDoneModel: FinishedWorkout) {
        let view = workoutFinishedScreenBuilder.build(with: .init(workoutDoneModel: workoutDoneModel)).view
        dependencies.navigation.show(view: view, animated: false)
    }
    
    func finishTrainingAssistantFlow() {
        dependencies.workoutFlowNavigation?.finishedTrainingAssistantFlow()
    }
}
