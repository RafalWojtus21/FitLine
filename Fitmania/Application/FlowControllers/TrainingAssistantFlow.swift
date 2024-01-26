//
//  TrainingAssistantFlow.swift
//  FitLine
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
    func showWorkoutSummaryScreen(workoutDoneModel: FinishedWorkout, shouldSaveWorkout: Bool)
    func editWorkoutPlan(_ plan: WorkoutPlan)
    func showYoutubePreview(videoID: String?)
    func finishTrainingAssistantFlow()
}

class TrainingAssistantFlowController: TrainingAssistantFlow, TrainingAssistantFlowNavigation {
    typealias Dependencies = HasNavigation & HasAppNavigation & HasWorkoutFlowNavigation
    
    struct ExtendedDependencies: Dependencies, HasTrainingAssistantFlowNavigation, HasWorkoutsHistoryService, HasCloudService, HasRealtimeDatabaseService, HasAuthManager, HasNotificationService {
        private let dependencies: Dependencies
        weak var appNavigation: AppNavigation?
        var navigation: Navigation { dependencies.navigation }
        weak var workoutFlowNavigation: WorkoutFlowNavigation?
        var trainingAssistantFlowNavigation: TrainingAssistantFlowNavigation?

        let workoutsHistoryService: WorkoutsHistoryService
        let cloudService: CloudService
        let realtimeDatabaseService: RealtimeDatabaseService
        let authManager: AuthManager
        let notificationService: NotificationService
        
        init(dependencies: Dependencies, trainingAssistantFlowNavigation: TrainingAssistantFlowNavigation) {
            self.dependencies = dependencies
            self.appNavigation = dependencies.appNavigation
            self.workoutFlowNavigation = dependencies.workoutFlowNavigation
            self.trainingAssistantFlowNavigation = trainingAssistantFlowNavigation
            self.realtimeDatabaseService = RealtimeDatabaseServiceImpl()
            self.authManager = AuthManagerImpl(auth: Auth.auth())
            self.cloudService = CloudServiceImpl(authManager: authManager, realtimeService: realtimeDatabaseService)
            self.workoutsHistoryService = WorkoutsHistoryServiceImpl(cloudService: cloudService)
            if let workoutFlowDependencies = dependencies as? WorkoutFlowController.ExtendedDependencies {
                self.notificationService = workoutFlowDependencies.notificationService
            } else {
                self.notificationService = NotificationServiceImpl()
            }
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
    private lazy var workoutSummaryScreenBuilder: WorkoutSummaryScreenBuilder = WorkoutSummaryScreenBuilderImpl(dependencies: extendedDependencies)
    private lazy var youtubePreviewScreenBuilder: YoutubePreviewScreenBuilder = YoutubePreviewScreenBuilderImpl(dependencies: extendedDependencies)
    
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
    
    func showWorkoutSummaryScreen(workoutDoneModel: FinishedWorkout, shouldSaveWorkout: Bool) {
        let view = workoutSummaryScreenBuilder.build(with: .init(workoutDoneModel: workoutDoneModel, shouldSaveWorkout: shouldSaveWorkout)).view
        dependencies.navigation.show(view: view, animated: false)
    }
    
    func editWorkoutPlan(_ plan: WorkoutPlan) {
        dependencies.workoutFlowNavigation?.editWorkoutPlan(plan)
    }
    
    func showYoutubePreview(videoID: String?) {
        let view = youtubePreviewScreenBuilder.build(with: .init(videoID: videoID)).view
        dependencies.navigation.present(view: view, animated: true, completion: nil)
    }
    
    func finishTrainingAssistantFlow() {
        dependencies.workoutFlowNavigation?.finishedTrainingAssistantFlow()
    }
}
