//
//  WorkoutsHistoryService.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 18/05/2023.
//

import Foundation
import RxSwift
import FirebaseDatabase
import FirebaseDatabaseSwift

protocol HasWorkoutsHistoryService {
    var workoutsHistoryService: WorkoutsHistoryService { get }
}

protocol WorkoutsHistoryService {
    var workoutsHistoryObservable: Observable<[FinishedWorkout]> { get }
    func saveFinishedWorkoutToHistory(finishedWorkout: FinishedWorkout) -> Completable
}

final class WorkoutsHistoryServiceImpl: WorkoutsHistoryService {
    private let bag = DisposeBag()
    private let cloudService: CloudService
    
    private var workoutsHistorySubject = BehaviorSubject<[FinishedWorkout]>(value: [])
    var workoutsHistoryObservable: Observable<[FinishedWorkout]> { return workoutsHistorySubject }
    
    init(cloudService: CloudService) {
        self.cloudService = cloudService
        observeWorkoutsHistoryInCloudService()
    }
    
    func observeWorkoutsHistoryInCloudService() {
        let addedWorkouts = cloudService.childAddedObservable(type: FinishedWorkout.self, endpoint: .workoutsHistory, decoder: nil)
            .withLatestFrom(workoutsHistorySubject) { addedWorkouts, workoutsHistory -> [FinishedWorkout] in
                var workoutsArray = workoutsHistory
                workoutsArray.append(addedWorkouts)
                return workoutsArray
            }
        
        let removedWorkouts = cloudService.childRemovedObservable(type: FinishedWorkout.self, endpoint: .workoutsHistory, decoder: nil)
            .withLatestFrom(workoutsHistorySubject) { deletedWorkout, workoutsHistory -> [FinishedWorkout] in
                return workoutsHistory.filter { workout in
                    return deletedWorkout.workoutID != workout.workoutID
                }
            }
        
        Observable.merge(addedWorkouts, removedWorkouts)
            .bind(to: workoutsHistorySubject)
            .disposed(by: bag)
    }
    
    func saveFinishedWorkoutToHistory(finishedWorkout: FinishedWorkout) -> Completable {
        return cloudService.savePersonalDataWithID(data: finishedWorkout, endpoint: .workoutsHistory, id: finishedWorkout.workoutID.workoutPlanID)
    }
}
