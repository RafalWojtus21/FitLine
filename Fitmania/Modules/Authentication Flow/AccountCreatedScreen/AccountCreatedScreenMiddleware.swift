//
//  AccountCreatedScreenMiddleware.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 18/04/2023.
//

import RxSwift

final class AccountCreatedScreenMiddlewareImpl: AccountCreatedScreenMiddleware, AccountCreatedScreenCallback {
    typealias Dependencies = HasAuthenticationFlowNavigation
    typealias Result = AccountCreatedScreenResult
    
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
            case .begin:
                break
            }
        }
        return .just(result)
    }
}
