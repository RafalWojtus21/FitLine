//
//  CalendarScreenInteractorTests.swift
//  FitmaniaTests
//
//  Created by Rafał Wojtuś on 20/06/2023.
//

@testable import Fitmania
import XCTest
import RxSwift
import RxTest
import RxBlocking

final class CalendarScreenInteractorTests: XCTestCase {
    
    struct Dependencies: CalendarScreenInteractorImpl.Dependencies {
        let calendarServiceMock = CalendarServiceMock()
        var calendarService: CalendarService { calendarServiceMock }
    }
    
    var dependencies: Dependencies!
    var sut: CalendarScreenInteractor!
    var bag: DisposeBag!
    var observer: TestableObserver<CalendarScreenResult>!
    
    
    override func setUp() {
        dependencies = Dependencies()
        
        sut = CalendarScreenInteractorImpl(dependencies: dependencies)
        bag = DisposeBag()
        observer = TestScheduler(initialClock: 0).createObserver(CalendarScreenResult.self)
    }
    
    func testGenerateCalendarItems() {
        let calendarItem1 = CalendarItem.init(date: Date(), isCurrentMonth: true, finishedWorkout: nil)
        let calendarItem2 = CalendarItem.init(date: Date(), isCurrentMonth: false, finishedWorkout: [FinishedWorkout(workoutPlanName: "plan", workoutID: WorkoutPlanID.init(workoutPlanID: UUID()), exercisesDetails: [], startDate: Date(), finishDate: Date())])
        
        let calendarMonth: CalendarMonth = .init(calendarItems: [calendarItem1, calendarItem2], monthAndYear: "June 2023")
        
        let calendarMonths = [calendarMonth]
        dependencies.calendarServiceMock.generateCalendarMonthsResponse = .just(calendarMonths)
        
        sut.generateCalendarItems()
            .subscribe(observer)
            .disposed(by: bag)
        
        let result = observer.events.compactMap { $0.value.element }
        XCTAssertEqual(result, [.partialState(.loadCalendarMonths(calendarMonths: calendarMonths, swipeDirection: .none))])
    }
    
    func testTriggerNextMonth() {
        let calendarItem1 = CalendarItem.init(date: Date(), isCurrentMonth: true, finishedWorkout: nil)
        let calendarItem2 = CalendarItem.init(date: Date(), isCurrentMonth: false, finishedWorkout: [FinishedWorkout(workoutPlanName: "plan", workoutID: WorkoutPlanID.init(workoutPlanID: UUID()), exercisesDetails: [], startDate: Date(), finishDate: Date())])
        
        let calendarMonth: CalendarMonth = .init(calendarItems: [calendarItem1, calendarItem2], monthAndYear: "June 2023")
        
        let calendarMonths = [calendarMonth]
        
        dependencies.calendarServiceMock.generateCalendarMonthsResponse = .just(calendarMonths)

        sut.triggerNextMonth()
            .subscribe(observer)
            .disposed(by: bag)
        
        let result = observer.events.compactMap { $0.value.element }
        XCTAssertEqual(result, [.partialState(.loadCalendarMonths(calendarMonths: calendarMonths, swipeDirection: .forward))])
    }
    
    func testTriggerPreviousMonth() {
        let calendarItem1 = CalendarItem.init(date: Date(), isCurrentMonth: true, finishedWorkout: nil)
        let calendarItem2 = CalendarItem.init(date: Date(), isCurrentMonth: false, finishedWorkout: [FinishedWorkout(workoutPlanName: "plan", workoutID: WorkoutPlanID.init(workoutPlanID: UUID()), exercisesDetails: [], startDate: Date(), finishDate: Date())])
        
        let calendarMonth: CalendarMonth = .init(calendarItems: [calendarItem1, calendarItem2], monthAndYear: "June 2023")
        
        let calendarMonths = [calendarMonth]
        
        dependencies.calendarServiceMock.generateCalendarMonthsResponse = .just(calendarMonths)

        sut.triggerPreviousMonth()
            .subscribe(observer)
            .disposed(by: bag)
        
        let result = observer.events.compactMap { $0.value.element }
        XCTAssertEqual(result, [.partialState(.loadCalendarMonths(calendarMonths: calendarMonths, swipeDirection: .backward))])
    }
    
    func testReloadData() {
        let calendarItem1 = CalendarItem.init(date: Date(), isCurrentMonth: true, finishedWorkout: nil)
        let calendarItem2 = CalendarItem.init(date: Date(), isCurrentMonth: false, finishedWorkout: [FinishedWorkout(workoutPlanName: "plan", workoutID: WorkoutPlanID.init(workoutPlanID: UUID()), exercisesDetails: [], startDate: Date(), finishDate: Date())])
        
        let calendarMonth: CalendarMonth = .init(calendarItems: [calendarItem1, calendarItem2], monthAndYear: "June 2023")
        
        let calendarMonths = [calendarMonth]
        
        dependencies.calendarServiceMock.generateCalendarMonthsResponse = .just(calendarMonths)

        sut.reloadData(for: 3, swipeDirection: .forward)
            .subscribe(observer)
            .disposed(by: bag)
        
        let result = observer.events.compactMap { $0.value.element }
        XCTAssertEqual(result, [.partialState(.loadCalendarMonths(calendarMonths: calendarMonths, swipeDirection: .forward))])
    }
}
