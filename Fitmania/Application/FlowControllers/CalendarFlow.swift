//
//  CalendarFlow.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 21/04/2023.
//

import UIKit

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
    
    struct ExtendedDependencies: Dependencies, HasCalendarFlowNavigation {
        private let dependencies: Dependencies
        weak var appNavigation: AppNavigation?
        var navigation: Navigation { dependencies.navigation }
        weak var calendarFlowNavigation: CalendarFlowNavigation?
        
        init(dependencies: Dependencies, calendarFlowNavigation: CalendarFlowNavigation) {
            self.dependencies = dependencies
            self.appNavigation = dependencies.appNavigation
            self.calendarFlowNavigation = calendarFlowNavigation
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
    
    // MARK: - AppNavigation
    
    func startCalendarFlow() -> BaseView? {
        nil
    }
}
