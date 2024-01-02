//
//  AppDelegate.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 05/04/2023.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import UserNotifications

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
        FirebaseApp.configure()
        setupInterface()
        requestNotificationAuthorization()
        return true
    }
    
    // MARK: - Private implementation
    
    private func setupInterface() {
        mainFlowController = AppFlowController(dependencies: fitmaniaDependencies)
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        mainFlowController?.startApplication()
    }
    
    private func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            guard granted else { return }
        }
    }
}
