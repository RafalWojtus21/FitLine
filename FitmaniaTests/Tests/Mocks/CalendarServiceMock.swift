//
//  CalendarServiceMock.swift
//  FitmaniaTests
//
//  Created by Rafał Wojtuś on 14/06/2023.
//

import Foundation
import RxSwift
import RxRelay

@testable import Fitmania

final class CalendarServiceMock: CalendarService {
    
    var triggerPreviousMonthResponse: CompletableEvent = .completed
    func triggerPreviousMonth() -> Completable {
        triggerPreviousMonthResponse.asCompletable()
    }
    
    var triggerNextMonthResponse: CompletableEvent = .completed
    func triggerNextMonth() -> Completable {
        triggerNextMonthResponse.asCompletable()
    }
    
    var switchMonthResponse: CompletableEvent = .completed
    func switchMonth(offset: Int) -> Completable {
        switchMonthResponse.asCompletable()
    }
    
    var generateCalendarMonthsResponse: Observable<[CalendarMonth]> = Observable.never()
    func generateCalendarMonths() -> Observable<[CalendarMonth]> {
        return generateCalendarMonthsResponse
            .compactMap { $0 }
            .catch { error in
                Observable.error(error)
            }
    }
    
}
