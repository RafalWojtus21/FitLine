//
//  CalendarScreenInteractor.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 06/06/2023.
//

import RxSwift

final class CalendarScreenInteractorImpl: CalendarScreenInteractor {
    
    // MARK: Properties
    
    typealias Dependencies = HasCalendarService
    typealias Result = CalendarScreenResult
    
    private let dependencies: Dependencies
    
    // MARK: Initialization
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    // MARK: Public Implementation
    
    func generateCalendarItems() -> Observable<CalendarScreenResult> {
        loadCalendarItems(swipeDirection: .none)
    }
    
    func triggerPreviousMonth() -> Observable<CalendarScreenResult> {
        dependencies.calendarService.triggerPreviousMonth()
            .andThen(loadCalendarItems(swipeDirection: .backward))
    }
    
    func triggerNextMonth() -> Observable<CalendarScreenResult> {
        dependencies.calendarService.triggerNextMonth()
            .andThen(loadCalendarItems(swipeDirection: .forward))
    }
    
    func reloadData(for offset: Int, swipeDirection: CalendarPageSwipeDirection) -> Observable<CalendarScreenResult> {
        dependencies.calendarService.switchMonth(offset: offset)
            .andThen(loadCalendarItems(swipeDirection: swipeDirection))
    }
    
    // MARK: Private Implementation
    
    private func loadCalendarItems(swipeDirection: CalendarPageSwipeDirection) -> Observable<CalendarScreenResult> {
        dependencies.calendarService.generateCalendarMonths()
            .map { calendarMonths in
                    .partialState(.loadCalendarMonths(calendarMonths: calendarMonths, swipeDirection: swipeDirection))
            }
    }
}
