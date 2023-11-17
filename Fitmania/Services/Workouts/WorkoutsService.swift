//
//  WorkoutsService.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 25/04/2023.
//

import Foundation
import RxSwift
import FirebaseDatabase
import FirebaseDatabaseSwift

protocol HasWorkoutsService {
    var workoutsService: WorkoutsService { get }
}

protocol WorkoutsService {
    func fetchAllExercises() -> Single<[WorkoutPart]>
    func saveNewPersonalTrainingPlan(exercises: [WorkoutPart]) -> Completable
    func fetchAllWorkouts() -> Observable<[WorkoutPart]>
    func deleteWorkoutPlan(id: WorkoutPlanID) -> Completable
    var workoutsObservable: Observable<[WorkoutPart]> { get }
}

final class WorkoutsServiceImpl: WorkoutsService {
    private let bag = DisposeBag()
    private let cloudService: CloudService

    private var workoutsSubject = BehaviorSubject<[WorkoutPart]>(value: [])
    var workoutsObservable: Observable<[WorkoutPart]> { return workoutsSubject }
    
    init(cloudService: CloudService) {
        self.cloudService = cloudService
        observeWorkoutsInCloudService()
    }
    
    func saveNewPersonalTrainingPlan(exercises: [WorkoutPart]) -> Completable {
        guard let id = exercises.first?.workoutPlanID, !exercises.isEmpty else {
            return Completable.error(DatabaseError.invalidWorkoutPlan)
        }
        return cloudService.savePersonalDataWithID(data: exercises, endpoint: .workouts, id: id.workoutPlanID)
    }
    
    func fetchAllExercises() -> Single<[WorkoutPart]> {
        return cloudService.fetchPersonalDataSingle(type: [WorkoutPart].self, endpoint: .workouts)
    }
    
    func fetchAllWorkouts() -> Observable<[WorkoutPart]> {
        return cloudService.fetchPersonalDataObservable(type: [WorkoutPart].self, endpoint: .workouts)
    }
    
    func deleteWorkoutPlan(id: WorkoutPlanID) -> Completable {
        cloudService.deletePersonalDataWithID(endpoint: .workouts, dataID: id.workoutPlanID)
    }
    
    func observeWorkoutsInCloudService() {
        let addedWorkouts = cloudService.childAddedObservable(type: [WorkoutPart].self, endpoint: .workouts, decoder: nil)
            .withLatestFrom(workoutsSubject) { addedParts, workouts -> [WorkoutPart] in
                workouts + addedParts
            }
        let removedWorkouts = cloudService.childRemovedObservable(type: [WorkoutPart].self, endpoint: .workouts, decoder: nil)
            .withLatestFrom(workoutsSubject) { deletedParts, workouts -> [WorkoutPart] in
                return workouts.filter { workoutPart in
                    return !deletedParts.contains(where: { $0.workoutPlanID == workoutPart.workoutPlanID })
                }
            }
        Observable.merge(addedWorkouts, removedWorkouts)
            .subscribe(onNext: { [weak self] exercises in
                guard let self else { return }
                self.workoutsSubject.onNext(exercises)
            })
            .disposed(by: bag)
    }
}
