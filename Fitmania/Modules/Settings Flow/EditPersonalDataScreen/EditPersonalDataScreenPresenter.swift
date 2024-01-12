//
//  EditPersonalDataScreenPresenter.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 12/01/2024.
//

import RxSwift

final class EditPersonalDataScreenPresenterImpl: EditPersonalDataScreenPresenter {
    typealias View = EditPersonalDataScreenView
    typealias ViewState = EditPersonalDataScreenViewState
    typealias Middleware = EditPersonalDataScreenMiddleware
    typealias Interactor = EditPersonalDataScreenInteractor
    typealias Effect = EditPersonalDataScreenEffect
    typealias Result = EditPersonalDataScreenResult
    
    private let interactor: Interactor
    private let middleware: Middleware
    
    private let initialViewState: ViewState
    
    init(interactor: Interactor, middleware: Middleware, initialViewState: ViewState) {
        self.interactor = interactor
        self.middleware = middleware
        self.initialViewState = initialViewState
    }
    
    func bindIntents(view: View, triggerEffect: PublishSubject<Effect>) -> Observable<ViewState> {
        let intentResults = view.intents.flatMap { [unowned self] intent -> Observable<Result> in
            switch intent {
            case .viewLoaded:
                return interactor.fetchUserInfo()
            case .cellSelected(let userInfoType):
                return .just(.effect(.edit(userInfoType)))
            case .edit(let userInfoType, let newValue):
                return interactor.edit(userInfoType, newValue: newValue)
            case .doneButtonIntent:
                return interactor.saveUserInfo()
            }
        }
        return Observable.merge(middleware.middlewareObservable, intentResults)
            .flatMap { self.middleware.process(result: $0) }
            .scan(initialViewState, accumulator: { previousState, result -> ViewState in
                switch result {
                case .partialState(let partialState):
                    return partialState.reduce(previousState: previousState)
                case .effect(let effect):
                    triggerEffect.onNext(effect)
                    return previousState
                }
            })
            .startWith(initialViewState)
            .distinctUntilChanged()
    }
}
