//
//  CategoryExercisesListInteractor.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 25/04/2023.
//

import RxSwift
import Foundation

final class CategoryExercisesListInteractorImpl: CategoryExercisesListInteractor {
    typealias Dependencies = Any
    typealias Result = CategoryExercisesListResult
    
    private let dependencies: Dependencies
    private let input: CategoryExercisesListBuilderInput
    
    init(dependencies: Dependencies, input: CategoryExercisesListBuilderInput) {
        self.dependencies = dependencies
        self.input = input
    }
    
    func loadExercises() -> RxSwift.Observable<CategoryExercisesListResult> {
        guard let fileLocation = Bundle.main.url(forResource: "exercises", withExtension: "json") else { return .just(.effect(.somethingWentWrong)) }
        do {
            let data = try Data(contentsOf: fileLocation)
            let dataFromJson = try JSONDecoder().decode([Exercise].self, from: data)
            let exercises = dataFromJson.filter { $0.category == input.chosenCategory }
            return .just(.partialState(.loadExercises(exercises: exercises)))
        } catch {
            return .just(.effect(.somethingWentWrong))
        }
    }
}
