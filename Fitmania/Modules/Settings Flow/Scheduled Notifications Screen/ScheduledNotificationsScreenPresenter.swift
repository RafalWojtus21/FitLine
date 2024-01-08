//
//  ScheduledNotificationsScreenPresenter.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 08/01/2024.
//

import RxSwift

final class ScheduledNotificationsScreenPresenterImpl: ScheduledNotificationsScreenPresenter {
    typealias View = ScheduledNotificationsScreenView
    typealias ViewState = ScheduledNotificationsScreenViewState
    typealias Middleware = ScheduledNotificationsScreenMiddleware
    typealias Interactor = ScheduledNotificationsScreenInteractor
    typealias Effect = ScheduledNotificationsScreenEffect
    typealias Result = ScheduledNotificationsScreenResult
    
    private let interactor: Interactor
    private let middleware: Middleware
    
    private let initialViewState: ViewState
    
    init(interactor: Interactor, middleware: Middleware, initialViewState: ViewState) {
        self.interactor = interactor
        self.middleware = middleware
        self.initialViewState = initialViewState
    }
    
    func bindIntents(view: View, triggerEffect: PublishSubject<Effect>) -> Observable<ViewState> {
        let intentResults = view.intents.flatMap { [unowned self] intent -> Observable<Result> in
            switch intent {
            case .viewLoaded:
                return interactor.fetchPendingNotifications()
            case .deletePendingNotification(let identifier):
                return interactor.deletePendingNotification(identifier)
            }
        }
        return Observable.merge(middleware.middlewareObservable, intentResults)
            .flatMap { self.middleware.process(result: $0) }
            .scan(initialViewState, accumulator: { previousState, result -> ViewState in
                switch result {
                case .partialState(let partialState):
                    return partialState.reduce(previousState: previousState)
                case .effect(let effect):
                    triggerEffect.onNext(effect)
                    return previousState
                }
            })
            .startWith(initialViewState)
            .distinctUntilChanged()
    }
}
