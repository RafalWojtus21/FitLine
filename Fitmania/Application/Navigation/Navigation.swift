//
//  MainNavigation.swift
//  AcademyMVI
//
//  Created by Bart on 15/11/2021.
//

import UIKit

protocol HasNavigation {
    var navigation: Navigation { get }
}

protocol Navigation {
    func set(view: BaseView, animated: Bool)
    func show(view: BaseView, animated: Bool)
    func pop()
    func popToRootViewController(animated: Bool)
    func present(view: BaseView, animated: Bool, completion: (() -> Void)?)
    func dismiss(completion: (() -> Void)?, animated: Bool)
}

final class MainNavigation: Navigation {
    
    // MARK: - Properties
    
    private let navigationController: UINavigationController
    
    private var topViewController: UIViewController? {
        var topVC: UIViewController? = navigationController.topViewController
        while topVC?.presentedViewController != nil {
            topVC = topVC?.presentedViewController
            if let navCon = topVC as? UINavigationController {
                topVC = navCon.topViewController
            }
        }
        return topVC
    }
    
    private var activeNavigationController: UINavigationController {
        guard let navCon = topViewController?.navigationController else {
            return navigationController
        }
        return navCon
    }
    
    // MARK: - Initialization
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    // MARK: - Set
    
    func set(view: BaseView, animated: Bool) {
        guard let viewController = view as? UIViewController else { return }
        navigationController.setViewControllers([viewController], animated: animated)
    }
    
    // MARK: - Push
    
    func show(view: BaseView, animated: Bool ) {
        guard let viewController = view as? UIViewController else { return }
        viewController.modalPresentationStyle = .fullScreen
        if animated {
            activeNavigationController.show(viewController, sender: nil)
        } else {
            UIView.performWithoutAnimation {
                activeNavigationController.show(viewController, sender: nil)
            }
        }
    }
    
    func pop() {
        activeNavigationController.popViewController(animated: true)
    }
    
    func popToRootViewController(animated: Bool) {
        activeNavigationController.popToRootViewController(animated: animated)
    }
    
    // MARK: - Present
    
    func present(view: BaseView, animated: Bool, completion: (() -> Void)?) {
        guard let topViewController = topViewController else { return }
        if let alert = view as? UIAlertController {
            topViewController.present(alert, animated: true, completion: completion)
            return
        }
        guard let viewController = view as? UIViewController else { return }
        let navCon = view as? UINavigationController ?? UINavigationController.init(rootViewController: viewController)
        topViewController.present(navCon, animated: animated, completion: completion)
    }

    func dismiss(completion: (() -> Void)?, animated: Bool) {
        guard let presentedViewController = activeNavigationController.topViewController else { return }
        presentedViewController.dismiss(animated: animated, completion: completion)
    }
    
}
