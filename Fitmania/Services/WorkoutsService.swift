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
    var workoutDataHasChanged: Observable<WorkoutID> { get }
}

struct WorkoutID: Hashable, Equatable {
    let workoutID: String
    
    init(_ workoutID: String) {
        self.workoutID = workoutID
    }
}

final class WorkoutsServiceImpl: WorkoutsService {
    private let bag = DisposeBag()
    private let cloudService: CloudService
    
    private var workoutDataHasChangedSubject = PublishSubject<WorkoutID>()
    var workoutDataHasChanged: Observable<WorkoutID> { return workoutDataHasChangedSubject }
    
    init(cloudService: CloudService) {
        self.cloudService = cloudService
    }
    
    func saveNewPersonalTrainingPlan(exercises: [WorkoutPart]) -> Completable {
        return cloudService.savePersonalData(data: exercises, endpoint: .workouts)
            .andThen(notifyWorkoutsDataHasChanged(id: WorkoutID(UUID().uuidString)))
    }
    
    func fetchAllExercises() -> Single<[WorkoutPart]> {
        return cloudService.fetchPersonalDataSingle(type: [WorkoutPart].self, endpoint: .workouts)
    }
    
    func fetchAllWorkouts() -> Observable<[WorkoutPart]> {
        return cloudService.fetchPersonalDataObservable(type: [WorkoutPart].self, endpoint: .workouts)
    }
    
    private func notifyWorkoutsDataHasChanged(id: WorkoutID) -> Completable {
        return .deferred {
            self.workoutDataHasChangedSubject.onNext(id)
            return Completable.empty()
        }
    }
}
