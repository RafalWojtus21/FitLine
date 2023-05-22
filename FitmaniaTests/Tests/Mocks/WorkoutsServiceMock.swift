//
// WorkoutServiceMock.swift
// FitmaniaTests
//
// Created by Rafał Wojtuś on 19/05/2023.
//
import Foundation
import RxSwift
import RxCocoa
@testable import Fitmania
final class WorkoutsServiceMock: WorkoutsService {
    
  var saveNewPersonalPlanResponse: CompletableEvent = .completed
  func saveNewPersonalTrainingPlan(exercises: [WorkoutPart]) -> Completable {
    saveNewPersonalPlanResponse.asCompletable()
  }
    
  var fetchAllExercisesResponse: [WorkoutPart] = []
    var fetchAllExercisesResponse2: Single<[WorkoutPart]> = Single.never()

    func fetchAllExercises() -> Single<[WorkoutPart]> {
        return fetchAllExercisesResponse2
            .flatMap { object -> Single<[WorkoutPart]> in
                return .just(object)
            }
            .catch { error in
                Single.error(error)
            }
    }
    
    var fetchAllWorkoutsResponse: Observable<[WorkoutPart]> = Observable.never()
  func fetchAllWorkouts() -> Observable<[WorkoutPart]> {
      return fetchAllWorkoutsResponse
          .compactMap { $0 }
          .catch { error in
              Observable.error(error)
          }
  }
    
  var deleteWorkoutPlanResponse: CompletableEvent = .completed
  func deleteWorkoutPlan(id: WorkoutPlanID) -> Completable {
    deleteWorkoutPlanResponse.asCompletable()
  }
    
  var workoutsSubject = BehaviorSubject<[WorkoutPart]>(value: [])
  var workoutsObservable: Observable<[WorkoutPart]> { return workoutsSubject }

  var observeWorkoutsInCloudServiceResponse: [WorkoutPart] = []
  func observeWorkoutsInCloudService() {
    workoutsSubject.onNext(observeWorkoutsInCloudServiceResponse)
  }
}
