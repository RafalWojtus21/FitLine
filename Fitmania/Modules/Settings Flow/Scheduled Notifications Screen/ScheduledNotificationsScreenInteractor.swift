//
//  ScheduledNotificationsScreenInteractor.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 08/01/2024.
//

import RxSwift
import UserNotifications

final class ScheduledNotificationsScreenInteractorImpl: ScheduledNotificationsScreenInteractor {
    
    // MARK: Properties
    
    typealias Dependencies = HasNotificationService
    typealias Result = ScheduledNotificationsScreenResult
    
    private let dependencies: Dependencies
    
    // MARK: Initialization

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    // MARK: Public Implementation
    
    func fetchPendingNotifications() -> Observable<ScheduledNotificationsScreenResult> {
        dependencies.notificationService.getPendingNotifications()
            .map { notificationRequests -> ScheduledNotificationsScreenResult in
                if notificationRequests.isEmpty {
                    return .effect(.requestsListEmpty)
                } else {
                    let scheduledNotifications: [ScheduledNotificationsScreen.Notification] = notificationRequests.compactMap { notificationRequest in
                        let content = notificationRequest.content
                        guard let notificationTrigger = notificationRequest.trigger as? UNCalendarNotificationTrigger,
                              let nextTriggerDate = notificationTrigger.nextTriggerDate() else {
                            return .init(identifier: notificationRequest.identifier, title: content.title, body: content.body, scheduledDate: nil)
                        }
                        return .init(identifier: notificationRequest.identifier, title: content.title, body: content.body, scheduledDate: nextTriggerDate)
                    }
                    return .partialState(.fetchPendingNotifications(pendingNotifications: scheduledNotifications))
                }
            }
    }
    
    func deletePendingNotification(_ identifier: String) -> Observable<ScheduledNotificationsScreenResult> {
        dependencies.notificationService.deletePendingNotifications(withIdentifier: identifier)
        return fetchPendingNotifications()
    }
    
    // MARK: Private Implementation
}
