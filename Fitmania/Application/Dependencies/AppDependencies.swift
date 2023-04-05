//
//  AppDependencies.swift
//  AcademyMVI
//
//  Created by Bart on 15/11/2021.
//

import UIKit

struct AppDependencies: MainFlowController.Dependencies {
    
    // MARK: - Properties
    
    let navigation: Navigation
    
    // MARK: - Initialization
    
    init(navigationController: UINavigationController) {
        navigation = MainNavigation(navigationController: navigationController)
    }
    
}
