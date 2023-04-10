//
//  MainFlowController.swift
//  AcademyMVI
//
//  Created by Bart on 15/11/2021.
//

import Foundation

protocol HasAppNavigation {
    var appNavigation: AppNavigation? { get }
}

protocol AppNavigation: AnyObject {
    func startApplication()
    func showWelcomeScreen()
    func showLoginScreen()
    func showRegisterScreen()
    func showForgotPasswordScreen()
    func showCreateAccountScreen()
    func showAccountCreatedScreen()
}

final class MainFlowController: AppNavigation {
    typealias Dependencies = HasNavigation
    
    struct ExtendedDependencies: Dependencies, HasAppNavigation, HasAuthManager, HasValidationService, HasFirestoreService, HasCloudService {
        private let dependencies: Dependencies
        weak var appNavigation: AppNavigation?
        var navigation: Navigation { dependencies.navigation }
        
        let authManager: AuthManager = AuthManagerImpl()
        let validationService: ValidationService = ValidationServiceImpl()
        let firestoreService: FirestoreService
        let cloudService: CloudService
        
        init(dependencies: Dependencies, appNavigation: AppNavigation) {
            self.dependencies = dependencies
            self.appNavigation = appNavigation
            self.firestoreService = FirestoreServiceImpl(authManager: authManager)
            self.cloudService = CloudServiceImpl(authManager: authManager, firestoreService: firestoreService)
        }
    }
    
    // MARK: - Properties
    
    private let dependencies: Dependencies
    private lazy var extendedDependencies = ExtendedDependencies(dependencies: dependencies, appNavigation: self)
    
    // MARK: - Builders
    
    private lazy var welcomeScreenBuilder: WelcomeScreenBuilder = WelcomeScreenBuilderImpl(dependencies: extendedDependencies)
    private lazy var registerScreenBuilder: RegisterScreenBuilder = RegisterScreenBuilderImpl(dependencies: extendedDependencies)
    private lazy var loginScreenBuilder: LoginScreenBuilder = LoginScreenBuilderImpl(dependencies: extendedDependencies)
    private lazy var createAccountScreenBuilder: CreateAccountScreenBuilder = CreateAccountScreenBuilderImpl(dependencies: extendedDependencies)

    // MARK: - Initialization
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    // MARK: - AppNavigation
    
    func startApplication() {
        showWelcomeScreen()
    }
    
    func showWelcomeScreen() {
        let view = welcomeScreenBuilder.build(with: .init()).view
        dependencies.navigation.set(view: view, animated: false)
    }
    
    func showLoginScreen() {
        let view = loginScreenBuilder.build(with: .init()).view
        dependencies.navigation.show(view: view, animated: false)
    }
    
    func showRegisterScreen() {
        let view = registerScreenBuilder.build(with: .init()).view
        dependencies.navigation.present(view: view, animated: false, completion: nil)
    }
    
    func showForgotPasswordScreen() {
    }
    
    func showCreateAccountScreen() {
        let view = createAccountScreenBuilder.build(with: .init()).view
        dependencies.navigation.present(view: view, animated: false, completion: nil)
    }
    
    func showAccountCreatedScreen() {
    }
}
