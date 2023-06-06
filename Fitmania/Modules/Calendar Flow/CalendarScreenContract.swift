//
//  CalendarScreenContract.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 06/06/2023.
//

import RxSwift

enum CalendarScreenIntent {
    case viewLoaded
    case previousMonthButtonIntent
    case nextMonthButtonIntent
    case cellTappedIntent(item: CalendarItem)
    case idle
    case reloadDataForOffset(offset: Int, swipeDirection: CalendarPageSwipeDirection)
}

struct CalendarScreenViewState: Equatable {
    var calendarItems: [CalendarItem] = []
    var calendarMonths: [CalendarMonth] = []
    var selectedMonthName: String = ""
    var swipeDirection: CalendarPageSwipeDirection = .none
    var shouldReloadCollectionView = false
    var shouldSetPages = false
}

enum CalendarScreenEffect: Equatable {
    case showDayPreview(item: CalendarItem)
    case idle
}

struct CalendarScreenBuilderInput {
}

protocol CalendarScreenCallback {
}

enum CalendarScreenResult: Equatable {
    case partialState(_ value: CalendarScreenPartialState)
    case effect(_ value: CalendarScreenEffect)
}

enum CalendarScreenPartialState: Equatable {
    case loadCalendarData(calendarItems: [CalendarItem], selectedMonthName: String)
    case loadCalendarMonths(calendarMonths: [CalendarMonth], swipeDirection: CalendarPageSwipeDirection)
    func reduce(previousState: CalendarScreenViewState) -> CalendarScreenViewState {
        var state = previousState
        state.shouldReloadCollectionView = false
        state.shouldSetPages = false
        switch self {
        case .loadCalendarData(calendarItems: let calendarItems, selectedMonthName: let selectedMonthName):
            state.calendarItems = calendarItems
            state.selectedMonthName = selectedMonthName
        case .loadCalendarMonths(calendarMonths: let calendarMonths, swipeDirection: let swipeDirection):
            state.calendarMonths = calendarMonths
            state.swipeDirection = swipeDirection
            state.shouldReloadCollectionView = true
            state.shouldSetPages = true
        }
        return state
    }
}

protocol CalendarScreenBuilder {
    func build(with input: CalendarScreenBuilderInput) -> CalendarScreenModule
}

struct CalendarScreenModule {
    let view: CalendarScreenView
    let callback: CalendarScreenCallback
}

protocol CalendarScreenView: BaseView {
    var intents: Observable<CalendarScreenIntent> { get }
    func render(state: CalendarScreenViewState)
}

protocol CalendarScreenPresenter: AnyObject, BasePresenter {
    func bindIntents(view: CalendarScreenView, triggerEffect: PublishSubject<CalendarScreenEffect>) -> Observable<CalendarScreenViewState>
}

protocol CalendarScreenInteractor: BaseInteractor {
    func generateCalendarItems() -> Observable<CalendarScreenResult>
    func triggerPreviousMonth() -> Observable<CalendarScreenResult>
    func triggerNextMonth() -> Observable<CalendarScreenResult>
    func reloadData(for offset: Int, swipeDirection: CalendarPageSwipeDirection) -> Observable<CalendarScreenResult>
}

protocol CalendarScreenMiddleware {
    var middlewareObservable: Observable<CalendarScreenResult> { get }
    func process(result: CalendarScreenResult) -> Observable<CalendarScreenResult>
}
