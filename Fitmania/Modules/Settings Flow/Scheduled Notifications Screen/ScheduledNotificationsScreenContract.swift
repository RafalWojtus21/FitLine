//
//  ScheduledNotificationsScreenContract.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 08/01/2024.
//

import RxSwift
import Foundation

enum ScheduledNotificationsScreen {
    struct Notification: Equatable {
        let identifier: String
        let title: String
        let body: String
        let scheduledDate: Date?
    }
}

enum ScheduledNotificationsScreenIntent {
    case viewLoaded
    case deletePendingNotification(_ identifier: String)
}

struct ScheduledNotificationsScreenViewState: Equatable {
    var scheduledNotifications: [ScheduledNotificationsScreen.Notification] = []
}

enum ScheduledNotificationsScreenEffect: Equatable {
    case notificationRequestRemoved
    case requestsListEmpty
}

struct ScheduledNotificationsScreenBuilderInput {
}

protocol ScheduledNotificationsScreenCallback {
}

enum ScheduledNotificationsScreenResult: Equatable {
    case partialState(_ value: ScheduledNotificationsScreenPartialState)
    case effect(_ value: ScheduledNotificationsScreenEffect)
}

enum ScheduledNotificationsScreenPartialState: Equatable {
    case fetchPendingNotifications(pendingNotifications: [ScheduledNotificationsScreen.Notification])
    func reduce(previousState: ScheduledNotificationsScreenViewState) -> ScheduledNotificationsScreenViewState {
        var state = previousState
        switch self {
        case .fetchPendingNotifications(pendingNotifications: let pendingNotifications):
            state.scheduledNotifications = pendingNotifications
        }
        return state
    }
}

protocol ScheduledNotificationsScreenBuilder {
    func build(with input: ScheduledNotificationsScreenBuilderInput) -> ScheduledNotificationsScreenModule
}

struct ScheduledNotificationsScreenModule {
    let view: ScheduledNotificationsScreenView
    let callback: ScheduledNotificationsScreenCallback
}

protocol ScheduledNotificationsScreenView: BaseView {
    var intents: Observable<ScheduledNotificationsScreenIntent> { get }
    func render(state: ScheduledNotificationsScreenViewState)
}

protocol ScheduledNotificationsScreenPresenter: AnyObject, BasePresenter {
    func bindIntents(view: ScheduledNotificationsScreenView, triggerEffect: PublishSubject<ScheduledNotificationsScreenEffect>) -> Observable<ScheduledNotificationsScreenViewState>
}

protocol ScheduledNotificationsScreenInteractor: BaseInteractor {
    func fetchPendingNotifications() -> Observable<ScheduledNotificationsScreenResult>
    func deletePendingNotification(_ identifier: String) -> Observable<ScheduledNotificationsScreenResult>
}

protocol ScheduledNotificationsScreenMiddleware {
    var middlewareObservable: Observable<ScheduledNotificationsScreenResult> { get }
    func process(result: ScheduledNotificationsScreenResult) -> Observable<ScheduledNotificationsScreenResult>
}
