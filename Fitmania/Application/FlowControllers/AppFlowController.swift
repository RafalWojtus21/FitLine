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
    func startOnboardingFlow()
    func finishedOnboarding(type: OnboardingExit)
    func startAuthenticationFlow(type: OnboardingExit)
    func dismiss()
}

final class AppFlowController: AppNavigation {
    typealias Dependencies = HasNavigation
    
    struct ExtendedDependencies: Dependencies, HasAppNavigation {
        private let dependencies: Dependencies
        weak var appNavigation: AppNavigation?
        var navigation: Navigation { dependencies.navigation }
        
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
    // var, optional
    
    // MARK: - Initialization
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    // MARK: - AppNavigation
    
    func startApplication() {
        startOnboardingFlow()
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
}