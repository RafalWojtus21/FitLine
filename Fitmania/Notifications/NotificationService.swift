//
//  NotificationService.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 05/01/2024.
//

import Foundation
import UserNotifications
import RxSwift

struct NotificationContent {
    let title: String
    let body: String
    let sound: UNNotificationSound
}

protocol HasNotificationService {
    var notificationService: NotificationService { get }
}

protocol NotificationService {
    func scheduleNewNotification(content: NotificationContent, for date: Date) -> Completable
    func getPendingNotifications() -> Observable<[UNNotificationRequest]>
}

final class NotificationServiceImpl: NotificationService {
    
    lazy var notificationCenter = UNUserNotificationCenter.current()
    
    func scheduleNewNotification(content: NotificationContent, for date: Date) -> Completable {
        Completable.create { completable in
            let notificationContent = UNMutableNotificationContent()
            notificationContent.title = content.title
            notificationContent.body = content.body
            notificationContent.sound = content.sound
            
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let requestId = UUID().uuidString
            let request = UNNotificationRequest(identifier: requestId, content: notificationContent, trigger: trigger)
            completable(.completed)
            
            self.notificationCenter.add(request) { error in
                if let error {
                    Log.notificationCenter.error("Failed to schedule the notification. \(error.localizedDescription)")
                    completable(.error(NotificationError.notificationSchedulingError))
                } else {
                    Log.notificationCenter.info("Notification scheduled successfully for \(date).")
                    completable(.completed)
                }
            }
            return Disposables.create()
        }
    }
    
    func getPendingNotifications() -> Observable<[UNNotificationRequest]> {
        Observable.create { observer in
            self.notificationCenter.getPendingNotificationRequests { observer.onNext($0) }
            return Disposables.create()
        }
    }
}
