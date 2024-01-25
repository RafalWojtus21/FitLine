//
//  SettingsFlow.swift
//  FitLine
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
    func showEditPersonalDataScreen()
    func finishedSettingsFlow()
}

class SettingsFlowController: SettingsFlow, SettingsFlowNavigation {
    
    typealias Dependencies = HasNavigation & HasAppNavigation & HasMainFlowNavigation
    
    struct ExtendedDependencies: Dependencies, HasSettingsFlowNavigation, HasAuthManager, HasNotificationService, HasRealtimeDatabaseService, HasCloudService {
        
        private let dependencies: Dependencies
        weak var appNavigation: AppNavigation?
        var navigation: Navigation { dependencies.navigation }
        weak var settingsFlowNavigation: SettingsFlowNavigation?
        weak var mainFlowNavigation: MainFlowNavigation?
        let authManager: AuthManager = AuthManagerImpl(auth: Auth.auth())
        let realtimeDatabaseService: RealtimeDatabaseService
        let cloudService: CloudService
        let notificationService: NotificationService

        init(dependencies: Dependencies, settingsFlowNavigation: SettingsFlowNavigation?) {
            self.dependencies = dependencies
            self.appNavigation = dependencies.appNavigation
            self.settingsFlowNavigation = settingsFlowNavigation
            self.realtimeDatabaseService = RealtimeDatabaseServiceImpl()
            self.cloudService = CloudServiceImpl(authManager: authManager, realtimeService: realtimeDatabaseService)
            self.notificationService = NotificationServiceImpl()
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
    private lazy var editPersonalDataScreenBuilder: EditPersonalDataScreenBuilder = EditPersonalDataScreenBuilderImpl(dependencies: extendedDependencies)

    // MARK: - AppNavigation
    
    func startSettingsFlow() -> BaseView {
        settingsScreenBuilder.build(with: .init()).view
    }
    
    func showScheduledNotifications() {
        let view = scheduledNotificationsScreenBuilder.build(with: .init()).view
        dependencies.navigation.present(view: view, animated: false, completion: nil)
    }
    
    func showEditPersonalDataScreen() {
        let view = editPersonalDataScreenBuilder.build(with: .init()).view
        dependencies.navigation.present(view: view, animated: false, completion: nil)
    }
    
    func finishedSettingsFlow() {
        dependencies.mainFlowNavigation?.finishedMainFlow()
    }
}
