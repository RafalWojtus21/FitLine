//
//  HomeFlow.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 19/04/2023.
//

import UIKit
import FirebaseAuth

protocol HasWorkoutFlowNavigation {
    var workoutFlowNavigation: WorkoutFlowNavigation? { get }
}

protocol WorkoutFlow {
    func startWorkoutFlow() -> BaseView
    func startCreateWorkoutFlow(trainingName: String)
    func startTrainingAssistantFlow(plan: WorkoutPlan)
}

protocol WorkoutFlowNavigation: AnyObject {
    func showWorkoutsListScreen()
    func startCreateWorkoutFlow(trainingName: String)
    func finishedCreateWorkoutFlow()
    func startTrainingAssistantFlow(plan: WorkoutPlan)
    func finishedTrainingAssistantFlow()
}

class WorkoutFlowController: WorkoutFlow, WorkoutFlowNavigation {
    typealias Dependencies = HasNavigation & HasAppNavigation & HasMainFlowNavigation
    
    struct ExtendedDependencies: Dependencies, HasWorkoutFlowNavigation, HasAuthManager, HasCloudService, HasRealtimeDatabaseService, HasWorkoutsService {
        private let dependencies: Dependencies
        weak var appNavigation: AppNavigation?
        weak var mainFlowNavigation: MainFlowNavigation?
        var navigation: Navigation { dependencies.navigation }
        var workoutFlowNavigation: WorkoutFlowNavigation?

        let authManager: AuthManager = AuthManagerImpl(auth: Auth.auth())
        let realtimeDatabaseService: RealtimeDatabaseService
        let cloudService: CloudService
        let workoutsService: WorkoutsService
        
        init(dependencies: Dependencies, workoutFlowNavigation: WorkoutFlowNavigation) {
            self.dependencies = dependencies
            self.appNavigation = dependencies.appNavigation
            self.mainFlowNavigation = dependencies.mainFlowNavigation
            self.workoutFlowNavigation = workoutFlowNavigation
            self.realtimeDatabaseService = RealtimeDatabaseServiceImpl()
            self.cloudService = CloudServiceImpl(authManager: authManager, realtimeService: realtimeDatabaseService)
            self.workoutsService = WorkoutsServiceImpl(cloudService: cloudService)
        }
    }
    
    // MARK: - Properties

    private let dependencies: Dependencies
    private lazy var extendedDependencies = ExtendedDependencies(dependencies: dependencies, workoutFlowNavigation: self)

    // MARK: - Flows
    
    private var createWorkoutFlowController: CreateWorkoutFlow?
    private var trainingAssistantFlowController: TrainingAssistantFlowController?
    
    // MARK: - Initialization

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    // MARK: - Builders
    
    private lazy var homeScreenBuilder: HomeScreenBuilder = HomeScreenBuilderImpl(dependencies: extendedDependencies)
    private lazy var workoutsListBuilder: WorkoutsListScreenBuilder = WorkoutsListScreenBuilderImpl(dependencies: extendedDependencies)
    
    // MARK: - AppNavigation
    
    func startWorkoutFlow() -> BaseView {
        homeScreenBuilder.build(with: .init()).view
    }
    
    func showWorkoutsListScreen() {
        let view = workoutsListBuilder.build(with: .init()).view
        dependencies.navigation.show(view: view, animated: false)
    }
    
    func startCreateWorkoutFlow(trainingName: String) {
        createWorkoutFlowController = CreateWorkoutFlowController(dependencies: extendedDependencies)
        createWorkoutFlowController?.startCreateWorkoutFlow(trainingName: trainingName)
    }
    
    func finishedCreateWorkoutFlow() {
        createWorkoutFlowController = nil
        dependencies.navigation.popToTargetViewController(controllerType: WorkoutsListScreenViewController.self, animated: false)
    }
    
    func startTrainingAssistantFlow(plan: WorkoutPlan) {
        trainingAssistantFlowController = TrainingAssistantFlowController(dependencies: extendedDependencies)
        trainingAssistantFlowController?.startTrainingAssistantFlow(plan: plan)
    }
    
    func finishedTrainingAssistantFlow() {
        trainingAssistantFlowController = nil
    }
}
