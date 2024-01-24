//
//  CreateWorkoutFlow.swift
//  FitLine
//
//  Created by Rafał Wojtuś on 26/04/2023.
//

import UIKit
import FirebaseAuth

protocol HasCreateWorkoutFlow {
    var createWorkoutFlowNavigation: CreateWorkoutFlowNavigation? { get }
}

protocol CreateWorkoutFlow {
    func startCreateWorkoutFlow(trainingName: String)
    func editWorkoutPlan(_ workoutPlan: WorkoutPlan)
}

protocol CreateWorkoutFlowNavigation: AnyObject {
    func showWorkoutSetupScreen(trainingName: String)
    func showWorkoutCategoryListScreen()
    func showCategoryExercisesListScreen(category: Exercise.Category)
    func showAddExerciseScreen(exercise: Exercise)
    func showEditExerciseScreen(_ workoutPart: WorkoutPart) 
    func popToRootViewController()
    func finishCreateWorkoutFlow()
}

class CreateWorkoutFlowController: CreateWorkoutFlow, CreateWorkoutFlowNavigation {
    typealias Dependencies = HasNavigation & HasWorkoutFlowNavigation
    
    struct ExtendedDependencies: Dependencies, HasCreateWorkoutFlow, HasExercisesDataStore & HasValidationService & HasAuthManager & HasRealtimeDatabaseService & HasCloudService & HasWorkoutsService {
        private let dependencies: Dependencies
        weak var workoutFlowNavigation: WorkoutFlowNavigation?
        var navigation: Navigation { dependencies.navigation }
        weak var createWorkoutFlowNavigation: CreateWorkoutFlowNavigation?
        
        let authManager: AuthManager = AuthManagerImpl(auth: Auth.auth())
        let realtimeDatabaseService: RealtimeDatabaseService
        let cloudService: CloudService
        let workoutsService: WorkoutsService
        let exercisesDataStore: ExercisesDataStore
        let validationService: ValidationService

        init(dependencies: Dependencies, createWorkoutFlowNavigation: CreateWorkoutFlowNavigation) {
            self.dependencies = dependencies
            self.workoutFlowNavigation = dependencies.workoutFlowNavigation
            self.createWorkoutFlowNavigation = createWorkoutFlowNavigation
            self.realtimeDatabaseService = RealtimeDatabaseServiceImpl()
            self.cloudService = CloudServiceImpl(authManager: authManager, realtimeService: realtimeDatabaseService)
            self.workoutsService = WorkoutsServiceImpl(cloudService: cloudService)
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
    
    private lazy var workoutSetupBuilder: WorkoutSetupScreenBuilder = WorkoutSetupScreenBuilderImpl(dependencies: extendedDependencies)
    private lazy var workoutsCategoryListBuilder: WorkoutsCategoryListScreenBuilder = WorkoutsCategoryListScreenBuilderImpl(dependencies: extendedDependencies)
    private lazy var categoryExercisesListBuilder: CategoryExercisesListBuilder = CategoryExercisesListBuilderImpl(dependencies: extendedDependencies)
    private lazy var addExerciseBuilder: AddExerciseScreenBuilder = AddExerciseScreenBuilderImpl(dependencies: extendedDependencies)
    
    // MARK: - AppNavigation
    
    func startCreateWorkoutFlow(trainingName: String) {
        showWorkoutSetupScreen(trainingName: trainingName)
    }
    
    func editWorkoutPlan(_ workoutPlan: WorkoutPlan) {
        extendedDependencies.exercisesDataStore.loadWorkoutPlan(workoutPlan)
        showWorkoutSetupScreen(trainingName: workoutPlan.name)
    }
    
    func showWorkoutSetupScreen(trainingName: String) {
        let view = workoutSetupBuilder.build(with: .init(trainingName: trainingName)).view
        dependencies.navigation.show(view: view, animated: false)
    }
    
    func showWorkoutCategoryListScreen() {
        let view = workoutsCategoryListBuilder.build(with: .init()).view
        dependencies.navigation.show(view: view, animated: false)
    }
    
    func showCategoryExercisesListScreen(category: Exercise.Category) {
        let view = categoryExercisesListBuilder.build(with: .init(chosenCategory: category)).view
        dependencies.navigation.show(view: view, animated: false)
    }
    
    func showAddExerciseScreen(exercise: Exercise) {
        let view = addExerciseBuilder.build(with: .init(chosenExercise: exercise, exerciseToEdit: nil)).view
        dependencies.navigation.show(view: view, animated: false)
    }
    
    func showEditExerciseScreen(_ workoutPart: WorkoutPart) {
        let view = addExerciseBuilder.build(with: .init(chosenExercise: workoutPart.exercise, exerciseToEdit: workoutPart)).view
        dependencies.navigation.show(view: view, animated: false)
    }
    
    func popToRootViewController() {
        dependencies.navigation.popToTargetViewController(controllerType: WorkoutSetupScreenViewController.self, animated: false)
    }
    
    func finishCreateWorkoutFlow() {
        dependencies.workoutFlowNavigation?.finishedCreateWorkoutFlow()
    }
}
