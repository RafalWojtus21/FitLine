//
//  WorkoutsListScreenInteractor.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 20/04/2023.
//

import RxSwift
import Foundation
import RxCocoa

final class WorkoutsListScreenInteractorImpl: WorkoutsListScreenInteractor {
    
    // MARK: Properties
    
    typealias Dependencies = HasCloudService & HasWorkoutsService
    typealias Result = WorkoutsListScreenResult
    
    private let dependencies: Dependencies
    private let workoutsSubject = BehaviorSubject<[WorkoutPlan]>(value: [])
    
    // MARK: Initialization
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    // MARK: Public Implementation
    
    func loadTrainingPlans() -> Observable<WorkoutsListScreenResult> {
        dependencies.workoutsService.workoutDataHasChanged
            .map({ _ in })
            .startWith(())
            .flatMapLatest { _ in
                Observable.zip(self.dependencies.workoutsService.fetchAllWorkouts(), self.workoutsSubject)
            }
            .map({ exercises, currentWorkouts in
                let workoutPlans = exercises.reduce(into: [:]) { dict, part in
                    dict[part.workoutPlanID, default: []].append(part)
                }.compactMap { workoutPlanID, parts -> WorkoutPlan? in
                    guard let name = parts.first?.workoutPlanName, !parts.isEmpty else {
                        return nil
                    }
                    return WorkoutPlan(name: name, id: workoutPlanID, parts: parts)
                }
                let refreshedPlans = workoutPlans + currentWorkouts
                self.workoutsSubject.onNext(refreshedPlans)
                return .partialState(.updateTrainingPlans(plans: refreshedPlans))
            })
    }
}
