//
//  AppDelegate.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 05/04/2023.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    // MARK: - Properties
    var window: UIWindow?
    
    private var mainFlowController: AppNavigation?
    private lazy var navigationController: UINavigationController = {
        let navigationController = UINavigationController()
        return navigationController
    }()
    private lazy var fitmaniaDependencies = AppDependencies(navigationController: navigationController)
    
    // MARK: - UIApplicationDelegate
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupInterface()
        return true
    }
    
    // MARK: - Private implementation
    
    private func setupInterface() {
        mainFlowController = MainFlowController(dependencies: fitmaniaDependencies)
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        mainFlowController?.startApplication()
    }
}
