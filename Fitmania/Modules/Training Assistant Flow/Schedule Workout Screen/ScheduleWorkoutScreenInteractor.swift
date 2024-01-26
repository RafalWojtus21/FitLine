//
//  ScheduleWorkoutScreenInteractor.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 10/05/2023.
//

import RxSwift
import Foundation
import UserNotifications

final class ScheduleWorkoutScreenInteractorImpl: ScheduleWorkoutScreenInteractor {
    
    typealias Dependencies = HasNotificationService
    typealias Result = ScheduleWorkoutScreenResult
    
    private let dependencies: Dependencies
    private let chosenWorkout: WorkoutPlan
    private let notificationCenter = UNUserNotificationCenter.current()
    
    init(dependencies: Dependencies, chosenWorkout: WorkoutPlan) {
        self.dependencies = dependencies
        self.chosenWorkout = chosenWorkout
    }
    
    func calculateWorkoutDetails() -> Observable<ScheduleWorkoutScreenResult> {
        let totalWorkoutTimeInSeconds: Int = chosenWorkout.parts.reduce(0) { $0 + ($1.details.time ?? 0) + $1.details.breakTime }
        let totalWorkoutTimeInMinutes = Int(ceil(Double(totalWorkoutTimeInSeconds) / 60.0))
        let categories = Array(Set(chosenWorkout.parts.flatMap { $0.exercise.categories }))
        let numberOfSets = chosenWorkout.parts.compactMap { workoutPart in
            workoutPart.details.sets
        }.reduce(0, +)
        return .just(.partialState(.updateWorkoutInfo(totalWorkoutTimeInSeconds: totalWorkoutTimeInSeconds,
                                                      totalWorkoutTimeInMinutes: totalWorkoutTimeInMinutes,
                                                      totalNumberOfSets: numberOfSets,
                                                      categories: categories)))
    }
    
    func scheduleWorkoutNotification(for date: Date) -> Observable<ScheduleWorkoutScreenResult> {
        let notificationContent = NotificationContent(title: chosenWorkout.name, body: "It's time to workout!", sound: .default)
        return dependencies.notificationService.scheduleNewNotification(content: notificationContent, for: date)
            .andThen(.just(.effect(.workoutScheduled)))
            .catch { _ in
                    .just(.effect(.workoutScheduleError))
            }
    }
}
