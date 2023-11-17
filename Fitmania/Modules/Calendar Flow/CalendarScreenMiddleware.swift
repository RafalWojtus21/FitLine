//
//  CalendarScreenMiddleware.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 06/06/2023.
//

import RxSwift

final class CalendarScreenMiddlewareImpl: CalendarScreenMiddleware, CalendarScreenCallback {
    typealias Dependencies = HasCalendarFlowNavigation
    typealias Result = CalendarScreenResult
    
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
            case .showDayPreview:
                break
            default:
                break
            }
        }
        return .just(result)
    }
}
