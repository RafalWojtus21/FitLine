//
//  SettingsFlow.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 21/04/2023.
//

import UIKit
import FirebaseAuth

protocol HasSettingsFlowNavigation {
    var settingsFlowNavigation: SettingsFlowNavigation? { get }
}

protocol SettingsFlow {
    func startSettingsFlow() -> BaseView
}

protocol SettingsFlowNavigation: AnyObject {
    func showScheduledNotifications()
    func finishedSettingsFlow()
}

class SettingsFlowController: SettingsFlow, SettingsFlowNavigation {
    
    typealias Dependencies = HasNavigation & HasAppNavigation & HasMainFlowNavigation
    
    struct ExtendedDependencies: Dependencies, HasSettingsFlowNavigation, HasAuthManager, HasNotificationService {
        private let dependencies: Dependencies
        weak var appNavigation: AppNavigation?
        var navigation: Navigation { dependencies.navigation }
        weak var settingsFlowNavigation: SettingsFlowNavigation?
        weak var mainFlowNavigation: MainFlowNavigation?
        let authManager: AuthManager = AuthManagerImpl(auth: Auth.auth())
        let notificationService: NotificationService

        init(dependencies: Dependencies, settingsFlowNavigation: SettingsFlowNavigation?) {
            self.dependencies = dependencies
            self.appNavigation = dependencies.appNavigation
            self.settingsFlowNavigation = settingsFlowNavigation
            if let mainFlowDependencies = dependencies as? MainFlowController.ExtendedDependencies {
                self.notificationService = mainFlowDependencies.notificationService
            } else {
                self.notificationService = NotificationServiceImpl()
                return
            }
        }
    }
    
    // MARK: - Properties
    
    private let dependencies: Dependencies
    private lazy var extendedDependencies = ExtendedDependencies(dependencies: dependencies, settingsFlowNavigation: self)

    // MARK: - Initialization
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    // MARK: - Builders
    
    private lazy var settingsScreenBuilder: SettingsScreenBuilder = SettingsScreenBuilderImpl(dependencies: extendedDependencies)
    private lazy var scheduledNotificationsScreenBuilder: ScheduledNotificationsScreenBuilder = ScheduledNotificationsScreenBuilderImpl(dependencies: extendedDependencies)

    // MARK: - AppNavigation
    
    func startSettingsFlow() -> BaseView {
        settingsScreenBuilder.build(with: .init()).view
    }
    
    func showScheduledNotifications() {
        let view = scheduledNotificationsScreenBuilder.build(with: .init()).view
        dependencies.navigation.present(view: view, animated: false, completion: nil)
    }
    
    func finishedSettingsFlow() {
        dependencies.mainFlowNavigation?.finishedMainFlow()
    }
}
