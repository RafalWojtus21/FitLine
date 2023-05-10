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
    
    // MARK: Initialization
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    // MARK: Public Implementation
    
    func loadTrainingPlans() -> RxSwift.Observable<WorkoutsListScreenResult> {
        dependencies.workoutsService.workoutsObservable
            .map({ exercises in
                let dictionary = exercises.reduce(into: [:]) { dict, part in
                    dict[part.workoutPlanID, default: []].append(part)
                }
                let workoutPlans = dictionary.compactMap { workoutPlanID, parts -> WorkoutPlan? in
                    guard let name = parts.first?.workoutPlanName, !parts.isEmpty else {
                        return nil
                    }
                    return WorkoutPlan(name: name, id: workoutPlanID, parts: parts)
                }
                return .partialState(.updateTrainingPlans(plans: workoutPlans))
            })
            .asObservable()
    }
    
    func deleteTrainingPlan(id: WorkoutPlanID) -> RxSwift.Observable<WorkoutsListScreenResult> {
        dependencies.workoutsService.deleteWorkoutPlan(id: id)
            .andThen(.just(.effect(.workoutPlanDeleted)))
            .catch { _ in
                return .just(.effect(.somethingWentWrong))
            }
    }
}
