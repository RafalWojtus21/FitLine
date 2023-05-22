//
//  ExercisesDataStoreMock.swift
//  FitmaniaTests
//
//  Created by Rafał Wojtuś on 22/05/2023.
//

import Foundation
import RxSwift
import RxRelay

@testable import Fitmania

final class ExercisesDataStoreMock: ExercisesDataStore {
    
    var exercisesRelay = BehaviorRelay<[WorkoutPart]>(value: [])
    var trainingPlanNameRelay = BehaviorRelay<String>(value: "")
    var trainingPlanId = UUID()
}
