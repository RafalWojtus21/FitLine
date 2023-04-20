//
//  MainFlowController.swift
//  AcademyMVI
//
//  Created by Bart on 15/11/2021.
//

import UIKit
import FirebaseAuth

protocol HasAppNavigation {
    var appNavigation: AppNavigation? { get }
}

protocol AppNavigation: AnyObject {
    func startApplication()
    func startOnboardingFlow()
    func finishedOnboarding(type: OnboardingExit)
    func startAuthenticationFlow(type: OnboardingExit)
    func finishedAuthenticationFlow()
    func startMainFlow()
    func startHomeFlow()
    func finishedHomeFlow()
    func dismiss()
}

final class AppFlowController: AppNavigation {
    typealias Dependencies = HasNavigation
    
    struct ExtendedDependencies: Dependencies, HasAppNavigation, HasAuthManager {
        private let dependencies: Dependencies
        weak var appNavigation: AppNavigation?
        var navigation: Navigation { dependencies.navigation }
        let authManager: AuthManager = AuthManagerImpl(auth: Auth.auth())

        init(dependencies: Dependencies, appNavigation: AppNavigation) {
            self.dependencies = dependencies
            self.appNavigation = appNavigation
        }
    }
    
    // MARK: - Properties
    
    private let dependencies: Dependencies
    private lazy var extendedDependencies = ExtendedDependencies(dependencies: dependencies, appNavigation: self)
    
    // MARK: - Flows
    
    private lazy var onboardingFlowController: OnboardingFlow = OnboardingFlowController(dependencies: extendedDependencies)
    private lazy var authenticationFlowController: AuthenticationFlow = AuthenticationFlowController(dependencies: extendedDependencies)
    private lazy var mainFlowController: MainFlow = MainFlowController(dependencies: extendedDependencies)
    
    // MARK: - Builders
    
    // MARK: - Initialization
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    // MARK: - AppNavigation
    
    func startApplication() {
        extendedDependencies.authManager.isLoggedIn { isLoggedIn in
            switch isLoggedIn {
            case true: self.startMainFlow()
            case false: self.startOnboardingFlow()
            }
        }
    }
    
    func dismiss() {
        dependencies.navigation.dismiss(completion: nil, animated: true)
    }
    
    func startOnboardingFlow() {
        onboardingFlowController.startOnboarding()
    }
    
    func finishedOnboarding(type: OnboardingExit) {
        startAuthenticationFlow(type: type)
    }
    
    func startAuthenticationFlow(type: OnboardingExit) {
        authenticationFlowController.startAuthFlow(type: type)
    }
    
    func finishedAuthenticationFlow() {
      startHomeFlow()
    }
    
    func startMainFlow() {
      mainFlowController.showHomeScreen()
    }

    func startHomeFlow() {
    }

    func finishedHomeFlow() {
    }
}
