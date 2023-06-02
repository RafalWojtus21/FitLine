//
//  WorkoutsHistoryServiceMock.swift
//  FitmaniaTests
//
//  Created by Rafał Wojtuś on 02/06/2023.
//

import Foundation
import RxSwift
import RxCocoa
@testable import Fitmania
final class WorkoutsHistoryServiceMock: WorkoutsHistoryService {
    
    var workoutsHistorySubject = BehaviorSubject<[FinishedWorkout]>(value: [])
    var workoutsHistoryObservable: Observable<[FinishedWorkout]> { return workoutsHistorySubject }
    
    var saveFinishedWorkoutToHistoryResponse: CompletableEvent = .completed
    
    func saveFinishedWorkoutToHistory(finishedWorkout: FinishedWorkout) -> Completable {
        saveFinishedWorkoutToHistoryResponse.asCompletable()
    }
}
