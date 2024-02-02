//
//  OnboardingFlow.swift
//  FitLine
//
//  Created by Rafał Wojtuś on 17/04/2023.
//

import UIKit

enum OnboardingExit {
    case login
    case register
}

protocol HasOnboardingFlowNavigation {
    var onboardingFlowNavigation: OnboardingFlowNavigation? { get }
}

protocol OnboardingFlow {
    func startOnboarding()
}

protocol OnboardingFlowNavigation: AnyObject {
    func showWelcomeScreen()
    func showLoginScreen()
    func showRegisterScreen()
    func dismiss()
}

class OnboardingFlowController: OnboardingFlow, OnboardingFlowNavigation {
    typealias Dependencies = HasNavigation & HasAppNavigation
    
    struct ExtendedDependencies: Dependencies, HasOnboardingFlowNavigation {
        private let dependencies: Dependencies
        weak var appNavigation: AppNavigation?
        var navigation: Navigation { dependencies.navigation }
        weak var onboardingFlowNavigation: OnboardingFlowNavigation?

        init(dependencies: Dependencies, onboardingFlowNavigation: OnboardingFlowNavigation) {
            self.dependencies = dependencies
            self.appNavigation = dependencies.appNavigation
            self.onboardingFlowNavigation = onboardingFlowNavigation
        }
    }
    
    // MARK: - Properties
    
    private let dependencies: Dependencies
    private lazy var extendedDependencies = ExtendedDependencies(dependencies: dependencies, onboardingFlowNavigation: self)

    // MARK: - Initialization
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    // MARK: - Builders
    
    private lazy var welcomeScreenBuilder: WelcomeScreenBuilder = WelcomeScreenBuilderImpl(dependencies: extendedDependencies)
    
    // MARK: - AppNavigation
    
    func startOnboarding() {
        showWelcomeScreen()
    }
    
    func showWelcomeScreen() {
        let view = welcomeScreenBuilder.build(with: .init()).view
        dependencies.navigation.set(view: view, animated: true)
    }
    
    func showLoginScreen() {
        dependencies.appNavigation?.finishedOnboarding(type: .login)
    }

    func showRegisterScreen() {
        dependencies.appNavigation?.finishedOnboarding(type: .register)
    }
    
    func dismiss() {
        dependencies.appNavigation?.dismiss()
    }
}
