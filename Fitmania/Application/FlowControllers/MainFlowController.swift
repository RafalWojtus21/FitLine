//
//  MainFlowController.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 21/04/2023.
//

import UIKit

protocol HasMainFlowNavigation {
    var mainFlowNavigation: MainFlowNavigation? { get }
}

protocol MainFlow {
    func showHomeScreen()
}

protocol MainFlowNavigation: AnyObject {
}

class MainFlowController: MainFlow, MainFlowNavigation {
    typealias Dependencies = HasNavigation & HasAppNavigation
    
    struct ExtendedDependencies: Dependencies, HasMainFlowNavigation {
        private let dependencies: Dependencies
        weak var appNavigation: AppNavigation?
        var navigation: Navigation { dependencies.navigation }
        weak var mainFlowNavigation: MainFlowNavigation?
        
        init(dependencies: Dependencies, mainFlowNavigation: MainFlowNavigation) {
            self.dependencies = dependencies
            self.appNavigation = dependencies.appNavigation
            self.mainFlowNavigation = mainFlowNavigation
        }
    }
    
    // MARK: - Properties
    
    private let dependencies: Dependencies
    private lazy var extendedDependencies = ExtendedDependencies(dependencies: dependencies, mainFlowNavigation: self)
    
    // MARK: - Flows
    
    private lazy var calendarFlowController: CalendarFlow = CalendarFlowController(dependencies: extendedDependencies)
    private lazy var homeFlowController: WorkoutFlow = WorkoutFlowController(dependencies: extendedDependencies)
    private lazy var settingsFlowController: SettingsFlow = SettingsFlowController(dependencies: extendedDependencies)

    // MARK: - Initialization
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    // MARK: - Builders
    
    // MARK: - AppNavigation
    
    func tabBarViewControllers() -> [UINavigationController] {
        let calendarScreen = calendarFlowController.startCalendarFlow()
        let workoutScreen = homeFlowController.startWorkoutFlow()
        let settingsScreen = settingsFlowController.startSettingsFlow()
        
        let tabBarScreens = [calendarScreen, workoutScreen, settingsScreen]
        let tabBarTitles = [Localization.General.calendar, Localization.General.workout, Localization.General.settings]
        let tabBarIcons: [UIImage?] = [.systemImageName(SystemImage.calendarIcon), .systemImageName(SystemImage.homeIcon), .systemImageName(SystemImage.settingsIcon)]
        
        var viewControllers = [UINavigationController]()
        for index in 0 ..< tabBarScreens.count {
            let navigationController = UINavigationController(rootViewController: tabBarScreens[index] as? UIViewController ?? UIViewController())
            navigationController.tabBarItem = UITabBarItem(title: tabBarTitles[index], image: tabBarIcons[index], selectedImage: tabBarIcons[index])
            viewControllers.append(navigationController)
        }
        return viewControllers
    }
    
    func showHomeScreen() {
        dependencies.navigation.setTabBar(viewControllers: tabBarViewControllers(), animated: true, selectedTab: 1)
    }
    
    func dismiss() {
        dependencies.appNavigation?.dismiss()
    }
}
