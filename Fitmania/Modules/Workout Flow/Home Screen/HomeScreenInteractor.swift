//
//  HomeScreenInteractor.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 19/04/2023.
//

import RxSwift
import Foundation

final class HomeScreenInteractorImpl: HomeScreenInteractor {

    typealias Dependencies = HasWorkoutsHistoryService & HasCloudService
    typealias Result = HomeScreenResult
    
    private let dependencies: Dependencies
    

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    func fetchUserInfo() -> RxSwift.Observable<HomeScreenResult> {
        dependencies.cloudService.fetchPersonalDataSingle(type: UserInfo.self, endpoint: .userInfo)
            .map { userInfo in
                    .partialState(.setUserInfo(userInfo: userInfo))
            }
            .asObservable()
    }
    
    func subscribeForWorkoutsHistory() -> Observable<HomeScreenResult> {
        dependencies.workoutsHistoryService.workoutsHistoryObservable
            .map({ workoutsHistory in
                return .partialState(.updateWorkoutsHistory(workouts: workoutsHistory.sorted { $0.startDate > $1.startDate }))
            })
    }
    
    func setPersonalRecords() -> Observable<HomeScreenResult> {
        return dependencies.workoutsHistoryService.workoutsHistoryObservable
            .flatMapLatest { workoutsHistory in
                let personalRecordsObservable = Observable.just(
                    HomeScreenResult.partialState(.setPersonalRecords(personalRecords: self.calculatePersonalRecords(workoutsHistory)))
                )
                return personalRecordsObservable
            }
    }

    private func calculatePersonalRecords(_ workoutsHistory: [FinishedWorkout]) -> [Exercise: HomeScreen.PersonalRecordData] {
        var personalRecordsDictionary: [Exercise: HomeScreen.PersonalRecordData] = [:]

        workoutsHistory.forEach { finishedWorkout in
            finishedWorkout.exercisesDetails.forEach { detailedExercise in
                if let distance = detailedExercise.details?.compactMap({ detail in
                    if case .distance(let float) = detail {
                        return float
                    }
                    return nil
                }).max() {
                    self.updatePersonalRecord(exercise: detailedExercise.exercise, value: distance, date: finishedWorkout.finishDate, records: &personalRecordsDictionary)
                } else if let weight = detailedExercise.details?.compactMap({ detail in
                    if case .weight(let float) = detail {
                        return float
                    }
                    return nil
                }).max() {
                    self.updatePersonalRecord(exercise: detailedExercise.exercise, value: weight, date: finishedWorkout.finishDate, records: &personalRecordsDictionary)
                }
            }
        }

        return personalRecordsDictionary
    }
    
    private func updatePersonalRecord(exercise: Exercise, value: Float, date: Date, records: inout [Exercise: HomeScreen.PersonalRecordData]) {
        if let currentRecord = records[exercise]?.score {
            records[exercise] = .init(score: max(currentRecord, value), date: date)
        } else {
            records[exercise] = .init(score: value, date: date)
        }
    }
}
