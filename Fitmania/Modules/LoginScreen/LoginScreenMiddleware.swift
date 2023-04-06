//
//  LoginScreenMiddleware.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 07/04/2023.
//

import RxSwift

final class LoginScreenMiddlewareImpl: LoginScreenMiddleware, LoginScreenCallback {
    typealias Dependencies = HasAppNavigation
    typealias Result = LoginScreenResult
    
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
            case .showForgotPasswordScreen:
                dependencies.appNavigation?.showForgotPasswordScreen()
            case .showRegisterScreen:
                dependencies.appNavigation?.showRegisterScreen()
            default:
                break
            }
        }
        return .just(result)
    }
}
