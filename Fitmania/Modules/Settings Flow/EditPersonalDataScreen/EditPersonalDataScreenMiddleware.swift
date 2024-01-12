//
//  EditPersonalDataScreenMiddleware.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 12/01/2024.
//

import RxSwift

final class EditPersonalDataScreenMiddlewareImpl: EditPersonalDataScreenMiddleware, EditPersonalDataScreenCallback {
    typealias Dependencies = HasAppNavigation
    typealias Result = EditPersonalDataScreenResult
    
    private let dependencies: Dependencies

    private let middlewareSubject = PublishSubject<Result>()
    var middlewareObservable: Observable<Result> { return middlewareSubject }
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    func process(result: Result) -> Observable<Result> {
        switch result {
        case .partialState(_): break
        case .effect(let effect):
            switch effect {
            case .edit(_):
                break
            case .dismiss:
                dependencies.appNavigation?.dismiss()
            default:
                break
            }
        }
        return .just(result)
    }
}
