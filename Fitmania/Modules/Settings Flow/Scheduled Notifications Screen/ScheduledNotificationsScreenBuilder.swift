//
//  ScheduledNotificationsScreenBuilder.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 08/01/2024.
//

import UIKit
import RxSwift

final class ScheduledNotificationsScreenBuilderImpl: ScheduledNotificationsScreenBuilder {
    typealias Dependencies = ScheduledNotificationsScreenInteractorImpl.Dependencies & ScheduledNotificationsScreenMiddlewareImpl.Dependencies
    private let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
        
    func build(with input: ScheduledNotificationsScreenBuilderInput) -> ScheduledNotificationsScreenModule {
        let interactor = ScheduledNotificationsScreenInteractorImpl(dependencies: dependencies)
        let middleware = ScheduledNotificationsScreenMiddlewareImpl(dependencies: dependencies)
        let presenter = ScheduledNotificationsScreenPresenterImpl(interactor: interactor, middleware: middleware, initialViewState: ScheduledNotificationsScreenViewState())
        let view = ScheduledNotificationsScreenViewController(presenter: presenter)
        return ScheduledNotificationsScreenModule(view: view, callback: middleware)
    }
}
