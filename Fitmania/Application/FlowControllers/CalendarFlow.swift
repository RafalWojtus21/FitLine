//
//  CalendarFlow.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 21/04/2023.
//

import UIKit
import FirebaseAuth

protocol HasCalendarFlowNavigation {
    var calendarFlowNavigation: CalendarFlowNavigation? { get }
}

protocol CalendarFlow {
    func startCalendarFlow() -> BaseView?
}

protocol CalendarFlowNavigation: AnyObject {
}

class CalendarFlowController: CalendarFlow, CalendarFlowNavigation {
    typealias Dependencies = HasNavigation & HasAppNavigation
    
    struct ExtendedDependencies: Dependencies, HasCalendarFlowNavigation, HasRealtimeDatabaseService, HasAuthManager, HasCloudService, HasWorkoutsHistoryService, HasCalendarService {
        private let dependencies: Dependencies
        weak var appNavigation: AppNavigation?
        var navigation: Navigation { dependencies.navigation }
        weak var calendarFlowNavigation: CalendarFlowNavigation?
        
        let calendarService: CalendarService
        let workoutsHistoryService: WorkoutsHistoryService
        let authManager: AuthManager = AuthManagerImpl(auth: Auth.auth())
        let realtimeDatabaseService: RealtimeDatabaseService
        let cloudService: CloudService
        
        init(dependencies: Dependencies, calendarFlowNavigation: CalendarFlowNavigation) {
            self.dependencies = dependencies
            self.appNavigation = dependencies.appNavigation
            self.calendarFlowNavigation = calendarFlowNavigation
            realtimeDatabaseService = RealtimeDatabaseServiceImpl()
            cloudService = CloudServiceImpl(authManager: authManager, realtimeService: realtimeDatabaseService)
            workoutsHistoryService = WorkoutsHistoryServiceImpl(cloudService: cloudService)
            calendarService = CalendarServiceImpl(workoutsHistoryService: workoutsHistoryService)
        }
    }
    
    // MARK: - Properties
    
    private let dependencies: Dependencies
    private lazy var extendedDependencies = ExtendedDependencies(dependencies: dependencies, calendarFlowNavigation: self)

    // MARK: - Initialization
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    // MARK: - Builders
    
    private lazy var calendarScreenBuilder: CalendarScreenBuilder = CalendarScreenBuilderImpl(dependencies: extendedDependencies)
    
    // MARK: - AppNavigation
    
    func startCalendarFlow() -> BaseView? {
        calendarScreenBuilder.build(with: .init()).view
    }
}
