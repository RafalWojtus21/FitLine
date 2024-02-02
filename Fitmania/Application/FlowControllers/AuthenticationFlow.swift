//
//  AuthenticationFlow.swift
//  FitLine
//
//  Created by Rafał Wojtuś on 17/04/2023.
//

import UIKit
import FirebaseAuth

protocol HasAuthenticationFlowNavigation {
    var authFlowNavigation: AuthFlowNavigation? { get }
}

protocol AuthenticationFlow {
    func startAuthFlow(type: OnboardingExit)
}

protocol AuthFlowNavigation: AnyObject {
    func showLoginScreen()
    func showRegisterScreen()
    func showForgotPasswordScreen()
    func showCreateAccountScreen()
    func showAccountCreatedScreen()
    func dismiss()
    func showHomeScreen()
}

class AuthenticationFlowController: AuthenticationFlow, AuthFlowNavigation {
    typealias Dependencies = HasNavigation & HasAppNavigation
    
    struct ExtendedDependencies: Dependencies, HasAuthenticationFlowNavigation, HasAuthManager, HasValidationService, HasCloudService {
        let authManager: AuthManager = AuthManagerImpl(auth: Auth.auth())
        let validationService: ValidationService = ValidationServiceImpl()
        let cloudService: CloudService
        let realtimeDatabaseService: RealtimeDatabaseService
        
        private let dependencies: Dependencies
        weak var appNavigation: AppNavigation?
        var navigation: Navigation { dependencies.navigation }
        weak var authFlowNavigation: AuthFlowNavigation?

        init(dependencies: Dependencies, authFlowNavigation: AuthFlowNavigation) {
            self.dependencies = dependencies
            self.appNavigation = dependencies.appNavigation
            self.authFlowNavigation = authFlowNavigation
            self.realtimeDatabaseService = RealtimeDatabaseServiceImpl()
            self.cloudService = CloudServiceImpl(authManager: authManager, realtimeService: realtimeDatabaseService)
        }
    }
    
    // MARK: - Properties

    private let dependencies: Dependencies
    private lazy var extendedDependencies = ExtendedDependencies(dependencies: dependencies, authFlowNavigation: self)

    // MARK: - Initialization

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    // MARK: - Builders
    
    private lazy var registerScreenBuilder: RegisterScreenBuilder = RegisterScreenBuilderImpl(dependencies: extendedDependencies)
    private lazy var loginScreenBuilder: LoginScreenBuilder = LoginScreenBuilderImpl(dependencies: extendedDependencies)
    private lazy var createAccountScreenBuilder: CreateAccountScreenBuilder = CreateAccountScreenBuilderImpl(dependencies: extendedDependencies)
    private lazy var forgotPasswordScreenBuilder: ForgotPasswordScreenBuilder = ForgotPasswordScreenBuilderImpl(dependencies: extendedDependencies)
    private lazy var accountCreatedScreenBuilder: AccountCreatedScreenBuilder = AccountCreatedScreenBuilderImpl(dependencies: extendedDependencies)

    // MARK: - AppNavigation

    func startAuthFlow(type: OnboardingExit) {
        switch type {
        case .login:
            showLoginScreen()
        case .register:
            showRegisterScreen()
        }
    }
    
    func showLoginScreen() {
        let view = loginScreenBuilder.build(with: .init()).view
        dependencies.navigation.show(view: view, animated: true)
    }
    
    func showRegisterScreen() {
        let view = registerScreenBuilder.build(with: .init()).view
        dependencies.navigation.show(view: view, animated: true)
    }
    
    func showForgotPasswordScreen() {
        let view = forgotPasswordScreenBuilder.build(with: .init()).view
        dependencies.navigation.present(view: view, animated: true, completion: nil)
    }
    
    func showCreateAccountScreen() {
        let view = createAccountScreenBuilder.build(with: .init()).view
        dependencies.navigation.show(view: view, animated: true)
    }
    
    func showAccountCreatedScreen() {
        let view = accountCreatedScreenBuilder.build(with: .init()).view
        dependencies.navigation.show(view: view, animated: true)
    }
    
    func dismiss() {
        dependencies.appNavigation?.dismiss()
    }
    
    func showHomeScreen() {
        dependencies.appNavigation?.finishedAuthenticationFlow()
    }
}
