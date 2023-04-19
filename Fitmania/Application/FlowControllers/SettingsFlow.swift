//
//  SettingsFlow.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 21/04/2023.
//

import UIKit

protocol HasSettingsFlowNavigation {
    var settingsFlowNavigation: SettingsFlowNavigation? { get }
}

protocol SettingsFlow {
    func startSettingsFlow() -> BaseView?
}

protocol SettingsFlowNavigation: AnyObject {
}

class SettingsFlowController: SettingsFlow, SettingsFlowNavigation {
    typealias Dependencies = HasNavigation & HasAppNavigation
    
    struct ExtendedDependencies: Dependencies, HasSettingsFlowNavigation {
        private let dependencies: Dependencies
        weak var appNavigation: AppNavigation?
        var navigation: Navigation { dependencies.navigation }
        weak var settingsFlowNavigation: SettingsFlowNavigation?
        
        init(dependencies: Dependencies, settingsFlowNavigation: SettingsFlowNavigation?) {
            self.dependencies = dependencies
            self.appNavigation = dependencies.appNavigation
            self.settingsFlowNavigation = settingsFlowNavigation
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
    
    // MARK: - AppNavigation
    
    func startSettingsFlow() -> BaseView? {
        nil
    }
}
