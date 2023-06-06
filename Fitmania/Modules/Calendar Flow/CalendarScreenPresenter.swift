//
//  CalendarScreenPresenter.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 06/06/2023.
//

import RxSwift

final class CalendarScreenPresenterImpl: CalendarScreenPresenter {
    typealias View = CalendarScreenView
    typealias ViewState = CalendarScreenViewState
    typealias Middleware = CalendarScreenMiddleware
    typealias Interactor = CalendarScreenInteractor
    typealias Effect = CalendarScreenEffect
    typealias Result = CalendarScreenResult
    
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
                return interactor.generateCalendarItems()
            case .previousMonthButtonIntent:
                return interactor.triggerPreviousMonth()
            case .nextMonthButtonIntent:
                return interactor.triggerNextMonth()
            case .cellTappedIntent(item: let item):
                return .just(.effect(.showDayPreview(item: item)))
            case .idle:
                return .just(.effect(.idle))
            case .reloadDataForOffset(offset: let offset, swipeDirection: let swipeDirection):
                return interactor.reloadData(for: offset, swipeDirection: swipeDirection)
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
