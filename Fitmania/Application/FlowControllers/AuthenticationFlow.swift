//
//  AuthenticationFlow.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 17/04/2023.
//

import UIKit

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
    
    struct ExtendedDependencies: Dependencies, HasAuthenticationFlowNavigation, HasAuthManager, HasValidationService, HasFirestoreService, HasCloudService {
        let authManager: AuthManager = AuthManagerImpl()
        let validationService: ValidationService = ValidationServiceImpl()
        let firestoreService: FirestoreService
        let cloudService: CloudService
        
        private let dependencies: Dependencies
        weak var appNavigation: AppNavigation?
        var navigation: Navigation { dependencies.navigation }
        weak var authFlowNavigation: AuthFlowNavigation?

        init(dependencies: Dependencies, authFlowNavigation: AuthFlowNavigation) {
            self.dependencies = dependencies
            self.appNavigation = dependencies.appNavigation
            self.authFlowNavigation = authFlowNavigation
            self.firestoreService = FirestoreServiceImpl(authManager: authManager)
            self.cloudService = CloudServiceImpl(authManager: authManager, firestoreService: firestoreService)
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
        dependencies.navigation.show(view: view, animated: false)
    }
    
    func showRegisterScreen() {
        let view = registerScreenBuilder.build(with: .init()).view
        dependencies.navigation.present(view: view, animated: false, completion: nil)
    }
    
    func showForgotPasswordScreen() {
        let view = forgotPasswordScreenBuilder.build(with: .init()).view
        dependencies.navigation.present(view: view, animated: false, completion: nil)
    }
    
    func showCreateAccountScreen() {
        let view = createAccountScreenBuilder.build(with: .init()).view
        dependencies.navigation.present(view: view, animated: false, completion: nil)
    }
    
    func showAccountCreatedScreen() {
        let view = accountCreatedScreenBuilder.build(with: .init()).view
        dependencies.navigation.present(view: view, animated: false, completion: nil)
    }
    
    func dismiss() {
        dependencies.appNavigation?.dismiss()
    }
    
    func showHomeScreen() {
        dependencies.appNavigation?.finishedAuthenticationFlow()
    }
}
