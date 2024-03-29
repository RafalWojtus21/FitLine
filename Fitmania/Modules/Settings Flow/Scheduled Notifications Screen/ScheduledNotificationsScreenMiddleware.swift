//
//  ScheduledNotificationsScreenMiddleware.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 08/01/2024.
//

import RxSwift

final class ScheduledNotificationsScreenMiddlewareImpl: ScheduledNotificationsScreenMiddleware, ScheduledNotificationsScreenCallback {
    typealias Dependencies = HasAppNavigation
    typealias Result = ScheduledNotificationsScreenResult
    
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
            default:
                break
            }
        }
        return .just(result)
    }
}
