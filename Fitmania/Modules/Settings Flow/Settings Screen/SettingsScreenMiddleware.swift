//
//  SettingsScreenMiddleware.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 29/05/2023.
//

import RxSwift

final class SettingsScreenMiddlewareImpl: SettingsScreenMiddleware, SettingsScreenCallback {
    typealias Dependencies = HasSettingsFlowNavigation
    typealias Result = SettingsScreenResult
    
    private let dependencies: Dependencies

    private let middlewareSubject = PublishSubject<Result>()
    var middlewareObservable: Observable<Result> { return middlewareSubject }
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    func process(result: Result) -> Observable<Result> {
        switch result {
        case .partialState(_): break
        case .effect(let effect):
            switch effect {
            case .showWelcomeScreen:
                dependencies.settingsFlowNavigation?.finishedSettingsFlow()
            case .showScheduledTrainings:
                dependencies.settingsFlowNavigation?.showScheduledNotifications()
            case .showPersonalDetailsEdition:
                dependencies.settingsFlowNavigation?.showEditPersonalDataScreen()
            case .accountDeleted:
                dependencies.settingsFlowNavigation?.finishedSettingsFlow()
            default:
                break
            }
        }
        return .just(result)
    }
}
