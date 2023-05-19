//
//  HomeScreenInteractor.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 19/04/2023.
//

import RxSwift

final class HomeScreenInteractorImpl: HomeScreenInteractor {

    typealias Dependencies = HasWorkoutsHistoryService
    typealias Result = HomeScreenResult
    
    private let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    func subscribeForWorkoutsHistory() -> RxSwift.Observable<HomeScreenResult> {
        return dependencies.workoutsHistoryService.workoutsHistoryObservable
            .map({ workoutsHistory in
                return .partialState(.updateWorkoutsHistory(workouts: workoutsHistory.sorted { $0.startDate > $1.startDate }))
            })
    }
}
