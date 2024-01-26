//
//  YoutubePreviewScreenPresenter.swift
//  FitLine
//
//  Created by Rafał Wojtuś on 26/01/2024.
//

import RxSwift

final class YoutubePreviewScreenPresenterImpl: YoutubePreviewScreenPresenter {
    typealias View = YoutubePreviewScreenView
    typealias ViewState = YoutubePreviewScreenViewState
    typealias Middleware = YoutubePreviewScreenMiddleware
    typealias Interactor = YoutubePreviewScreenInteractor
    typealias Effect = YoutubePreviewScreenEffect
    typealias Result = YoutubePreviewScreenResult
    
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
