//
//  CalendarServiceTests.swift
//  FitmaniaTests
//
//  Created by Rafał Wojtuś on 14/06/2023.
//

@testable import Fitmania
import XCTest
import RxSwift
import RxTest
import RxBlocking

final class CalendarServiceTests: XCTestCase {
    var sut: CalendarService!
    var workoutsHistoryServiceMock: WorkoutsHistoryServiceMock!
    let bag = DisposeBag()
    
    override func setUp() {
        workoutsHistoryServiceMock = WorkoutsHistoryServiceMock()
        sut = CalendarServiceImpl(workoutsHistoryService: workoutsHistoryServiceMock)
    }
    
    func testTriggerNextMonthSuccess() {
        let result = try! sut.triggerNextMonth()
            .toArrayAndBlocking()
        XCTAssertEqual(result, .completed)
    }
    
    func testTriggerPreviousMonthSuccess() {
        let result = try! sut.triggerPreviousMonth()
            .toArrayAndBlocking()
        XCTAssertEqual(result, .completed)
    }
    
    func testSwitchMonthSuccess() {
        let result = try! sut.switchMonth(offset: 2)
            .toArrayAndBlocking()
        XCTAssertEqual(result, .completed)
    }
    
    func testGenerateCalendarMonths() {
        let calendar = Calendar.current

        let detailedExercises: [DetailedExercise] = [
            .init(exercise: Exercise(category: .back, name: "rowing"), details: nil),
            .init(exercise: Exercise(category: .biceps, name: "push ups"), details: [.repetitions(12)])
        ]
        let startDate = Date()
        let endDate = Date()
        let workout = FinishedWorkout(workoutPlanName: "Plan 1", workoutID: WorkoutPlanID(workoutPlanID: UUID()), exercisesDetails: detailedExercises, startDate: startDate, finishDate: endDate)
        let workoutSubject = BehaviorSubject<[CalendarMonth]>(value: [])
        
        workoutsHistoryServiceMock.workoutsHistorySubject.onNext([workout])
        sut.generateCalendarMonths()
            .subscribe(onNext: { value in
                workoutSubject.onNext(value)
            })
            .disposed(by: bag)
        
        let subjectValue = try! workoutSubject.value()
            
        let isWorkoutPresentOnSpecificDay = subjectValue.flatMap { $0.calendarItems }
            .first { calendar.isDate($0.date, inSameDayAs: startDate) }
            .flatMap { $0.finishedWorkout }
            .map { !$0.isEmpty } ?? false
        let areAllWorkoutsNil = subjectValue.flatMap { $0.calendarItems }
            .allSatisfy { $0.finishedWorkout == nil }
        let areRemainingWorkoutsNil = subjectValue.flatMap { $0.calendarItems }
            .filter { !calendar.isDate($0.date, inSameDayAs: startDate) }
            .allSatisfy { $0.finishedWorkout == nil }

        XCTAssertTrue(isWorkoutPresentOnSpecificDay)
        XCTAssertFalse(areAllWorkoutsNil)
        XCTAssertTrue(areRemainingWorkoutsNil)
    }
    
    func testCheckIfDidWorkoutReturnsNil() {
        workoutsHistoryServiceMock.workoutsHistorySubject.onNext([])
        let workoutSubject = BehaviorSubject<[CalendarMonth]>(value: [])

        sut.generateCalendarMonths()
            .subscribe(onNext: { value in
                workoutSubject.onNext(value)
            })
            .disposed(by: bag)
        
        let subjectValue = try! workoutSubject.value()
        
        let areAllWorkoutsNil = subjectValue.flatMap { $0.calendarItems }
            .allSatisfy { $0.finishedWorkout == nil }
        
        XCTAssertTrue(areAllWorkoutsNil)
    }
}
