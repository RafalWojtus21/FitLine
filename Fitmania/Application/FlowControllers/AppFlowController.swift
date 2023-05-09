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
    func finishedMainFlow()
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

    private var onboardingFlowController: OnboardingFlow?
    private var authenticationFlowController: AuthenticationFlow?
    private var mainFlowController: MainFlow?
    
    // MARK: - Builders
    
    // MARK: - Initialization
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    // MARK: - AppNavigation
    
    func startApplication() {
        switch extendedDependencies.authManager.isLoggedIn() {
        case true: self.startMainFlow()
        case false: self.startOnboardingFlow()
        }
    }
    
    func dismiss() {
        dependencies.navigation.dismiss(completion: nil, animated: true)
    }
    
    func startOnboardingFlow() {
        onboardingFlowController = OnboardingFlowController(dependencies: extendedDependencies)
        onboardingFlowController?.startOnboarding()
    }
    
    func finishedOnboarding(type: OnboardingExit) {
        onboardingFlowController = nil
        startAuthenticationFlow(type: type)
    }
    
    func startAuthenticationFlow(type: OnboardingExit) {
        authenticationFlowController = AuthenticationFlowController(dependencies: extendedDependencies)
        authenticationFlowController?.startAuthFlow(type: type)
    }
    
    func finishedAuthenticationFlow() {
        authenticationFlowController = nil
        startMainFlow()
    }
    
    func startMainFlow() {
        mainFlowController = MainFlowController(dependencies: extendedDependencies)
        mainFlowController?.startMainFlow()
    }
    
    func finishedMainFlow() {
        mainFlowController = nil
    }

    func startHomeFlow() {
    }
    
    func finishedHomeFlow() {
    }
}
