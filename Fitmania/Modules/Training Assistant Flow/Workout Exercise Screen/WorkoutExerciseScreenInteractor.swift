//
//  WorkoutExerciseScreenInteractor.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 11/05/2023.
//

import RxSwift
import UIKit

final class WorkoutExerciseScreenInteractorImpl: WorkoutExerciseScreenInteractor {
    
    // MARK: Properties
    
    typealias Dependencies = Any
    typealias Result = WorkoutExerciseScreenResult
    
    private let dependencies: Dependencies
    
    private let bag = DisposeBag()
    private var triggerExerciseSubject = PublishSubject<TriggerType>()
    private let pauser = BehaviorSubject<Bool>(value: true)
    private var detailedExercisesSubject = PublishSubject<[DetailedExercise]>()
    private var timeGone: Double = 0.0
    private var timeLeft: Double?
    private var timerScheduler: SchedulerType
    private var workoutPlan: WorkoutPlan
    private var workoutEvents: [WorkoutPartEvent] {
        workoutPlan.parts.flatMap { $0.generateWorkoutPartEvents() }
    }
    private var currentEventIndex: Int = 0
    private var startTime: Date?
    private var accumulatedTime: TimeInterval = 0
    private var isPaused = false
    private var workoutStartTime: Date?
    private var detailedExercisesArray: [DetailedExercise] = []
    private var exerciseDetailsSubject = BehaviorSubject<([DetailedExercise.Details], Int?)>(value: ([], nil))
    var detailedExercises: [DetailedExercise] = []
    private var currentExerciseStartDateSubject = BehaviorSubject<Date>(value: Date())
    private var currentExerciseFinishDateSubject = BehaviorSubject<Date>(value: Date())
    
    enum TriggerType {
        case initialExercise
        case nextExercise
    }
    
    // MARK: Initialization
    
    init(dependencies: Dependencies, timerScheduler: SchedulerType = MainScheduler.instance, workoutPlan: WorkoutPlan) {
        self.dependencies = dependencies
        self.timerScheduler = timerScheduler
        self.workoutPlan = workoutPlan
        self.timeLeft = Double(workoutEvents[0].duration ?? 0)
        self.workoutPlan = workoutPlan
    }
    
    // MARK: Public Implementation
    
    func loadEvents() -> Observable<WorkoutExerciseScreenResult> {
        return .just(.partialState(.loadWorkoutEvents(workoutEvents: workoutEvents)))
    }
    
    func observeForExercises() -> Observable<WorkoutExerciseScreenResult> {
        return triggerExerciseSubject
            .asObservable()
            .flatMapLatest { triggerType -> Observable<WorkoutExerciseScreenResult> in
                self.timeGone = 0.0
                self.accumulatedTime = 0.0
                switch triggerType {
                case .initialExercise:
                    return .merge(
                        .just(.partialState(.updateIntervalState(intervalState: .running))),
                        self.handleInitialExercise(),
                        .just(.partialState(.updateCurrentEventIndex(currentEventIndex: 0)))
                    )
                case .nextExercise:
                    return self.handleNextExercise()
                }
            }
    }
    
    func getCurrentExercise() -> Observable<WorkoutExerciseScreenResult> {
        let detailsTypes = workoutEvents[currentEventIndex].exercise.type.generatePossibleDetails()
        return .just(.partialState(.updateAvailableDetailsTypes(detailsTypes: detailsTypes)))
    }
    
    func saveDetailOfCurrentExercise(details: [String]) -> Observable<WorkoutExerciseScreenResult> {
        let possibleDetailsTypes = workoutEvents[currentEventIndex].exercise.type.generatePossibleDetails()
        var exerciseDetails: [DetailedExercise.Details] = []
        let currentEvent = workoutEvents[currentEventIndex]
         
        guard currentEvent.type == .rest else { return .just(.partialState(.idle)) }
        for (index, detailValue) in details.enumerated() {
            let detailType = possibleDetailsTypes[index]
            switch detailType {
            case .repetitions:
                if let repetitions = Int(detailValue) {
                    exerciseDetails.append(.repetitions(repetitions))
                }
            case .weight:
                if let weight = detailValue.floatValue {
                    exerciseDetails.append(.weight(weight))
                }
            case .distance:
                if let distance = detailValue.floatValue {
                    exerciseDetails.append(.distance(distance))
                }
            }
        }
        do {
            let startDate = try currentExerciseStartDateSubject.value()
            let finishDate = try currentExerciseFinishDateSubject.value()
            let totalTimeInterval = finishDate.timeIntervalSince(startDate)
            exerciseDetails.append(.totalTime(totalTimeInterval))
        } catch {
            return .just(.partialState(.idle))
        }
        exerciseDetailsSubject.onNext((exerciseDetails, currentEventIndex))
        return .just(.partialState(.idle))
    }
    
    func triggerFirstExercise() -> Observable<WorkoutExerciseScreenResult> {
        triggerExerciseSubject.onNext(.initialExercise)
        return .just(.partialState(.idle))
    }
    
    func triggerNextExercise() -> Observable<WorkoutExerciseScreenResult> {
        triggerExerciseSubject.onNext(.nextExercise)
        return resumeTimer()
    }
    
    func setTimer() -> Observable<WorkoutExerciseScreenResult> {
        let currentEventDuration = workoutEvents[currentEventIndex].duration
        // swiftlint:disable:next force_unwrapping
        let eventDurationTimeInterval: TimeInterval? = currentEventDuration != nil ? TimeInterval(currentEventDuration!) : nil
        self.timeLeft = Double(self.workoutEvents[self.currentEventIndex].duration ?? 0)
        startTime = Date()
        return Observable<Int>.interval(.milliseconds(1), scheduler: timerScheduler)
            .pausable(pauser)
            .take(until: { _ in
                return self.timeLeft == 0
            })
            .map { _ -> WorkoutExerciseScreenResult in
                guard let startTime = self.startTime, var timeLeft = self.timeLeft else { return .partialState(.isTimerRunning(isRunning: false))}
                guard let eventDurationTimeInterval else { return .partialState(.switchToPhysicalExerciseView(currentEventIndex: self.currentEventIndex)) }
                let currentTime = Date()
                let elapsedTime = currentTime.timeIntervalSince(startTime) + self.accumulatedTime
                let previousProgress = Float(elapsedTime) / Float(eventDurationTimeInterval)
                self.timeGone = elapsedTime
                timeLeft = eventDurationTimeInterval - elapsedTime
                let currentProgress = Float(elapsedTime) / Float(eventDurationTimeInterval)
                var intervalState: WorkoutExerciseScreen.IntervalState = .running
                if elapsedTime >= eventDurationTimeInterval {
                    timeLeft = 0
                    intervalState = .finished
                    if self.workoutEvents[self.currentEventIndex].type == .exercise {
                        self.triggerExerciseSubject.onNext(.nextExercise)
                    }
                }
                return .partialState(.updateCurrentTime(intervalState: intervalState, previousProgress: previousProgress, currentProgress: currentProgress, timeLeft: Int(ceil(timeLeft))))
            }
    }
    
    func pauseTimer() -> Observable<WorkoutExerciseScreenResult> {
        if let startTime, !isPaused {
            accumulatedTime += Date().timeIntervalSince(startTime)
            isPaused = true
            pauser.onNext(false)
        }
        return .just(.partialState(.updateIntervalState(intervalState: .paused)))
    }
    
    func resumeTimer() -> Observable<WorkoutExerciseScreenResult> {
        if isPaused {
            startTime = Date()
            isPaused = false
            pauser.onNext(true)
        }
        return .just(.partialState(.updateIntervalState(intervalState: .running)))
    }
    
    func openYoutubePreview() -> Observable<WorkoutExerciseScreenResult> {
        .just(.effect(.showYoutubePreview(id: workoutEvents[currentEventIndex].exercise.videoID)))
    }
    
    // MARK: Private Implementation
    
    private func handleInitialExercise() -> Observable<WorkoutExerciseScreenResult> {
        workoutStartTime = Date()
        return checkTypeOfExercise()
    }
    
    private func checkTypeOfExercise() -> Observable<WorkoutExerciseScreenResult> {
        let currentEvent = workoutEvents[currentEventIndex]
        
        if currentEvent.exercise.type.shouldMeasureTime {
            return handleCardioExercise()
        } else {
            return handlePhysicalExercise()
        }
    }
    
    private func handleCardioExercise() -> Observable<WorkoutExerciseScreenResult> {
        let currentEvent = workoutEvents[currentEventIndex]
        let duration = currentEvent.duration ?? 0
        switch currentEvent.type {
        case .exercise:
            currentExerciseStartDateSubject.onNext(Date())
            return .merge(setTimer(),
                          .just(.partialState(.shouldShowTimer(isTimerVisible: true))),
                          .just(.partialState(.updateAvailableDetailsTypes(detailsTypes: []))),
                          .just(.partialState(.setAnimationDuration(duration: duration))))
        case .rest:
            currentExerciseFinishDateSubject.onNext(Date())
            return .merge(setTimer(),
                          .just(.partialState(.shouldShowTimer(isTimerVisible: true))),
                          getCurrentExercise(),
                          .just(.partialState(.setAnimationDuration(duration: duration))))
        }
    }
    
    private func handlePhysicalExercise() -> Observable<WorkoutExerciseScreenResult> {
        let currentEvent = workoutEvents[currentEventIndex]
        let duration = currentEvent.duration ?? 0
        switch currentEvent.type {
        case .exercise:
            currentExerciseStartDateSubject.onNext(Date())
            return .merge(.just(.partialState(.shouldShowTimer(isTimerVisible: false))),
                          .just(.partialState(.triggerAnimation)),
                          .just(.partialState(.updateAvailableDetailsTypes(detailsTypes: []))))
        case .rest:
            currentExerciseFinishDateSubject.onNext(Date())
            return .merge(setTimer(),
                          .just(.partialState(.shouldShowTimer(isTimerVisible: true))),
                          getCurrentExercise(),
                          .just(.partialState(.setAnimationDuration(duration: duration))))
        }
    }
    
    private func handleNextExercise() -> Observable<WorkoutExerciseScreenResult> {
        let currentEvent = workoutEvents[currentEventIndex]
        switch currentEvent.type {
        case .rest:
            do {
                let details: [DetailedExercise.Details]?
                if try exerciseDetailsSubject.value().1 == currentEventIndex {
                    details = try exerciseDetailsSubject.value().0
                } else {
                    details = nil
                }
                detailedExercises.append(DetailedExercise(exercise: currentEvent.exercise, details: details))
            } catch {
                return .just(.effect(.somethingWentWrong))
            }
        default: break
        }
        
        return checkIfLastEvent()
    }
    
    private func checkIfLastEvent() -> Observable<WorkoutExerciseScreenResult> {
        if isLastEvent() {
            return handleLastEvent()
        } else {
            return handleNonLastEvent()
        }
    }
    
    private func isLastEvent() -> Bool {
        currentEventIndex == workoutEvents.count - 1
    }
    
    private func handleLastEvent() -> Observable<WorkoutExerciseScreenResult> {
        detailedExercisesSubject.onNext(detailedExercises)
        let finishedWorkout = FinishedWorkout(workoutPlanName: workoutPlan.name, workoutID: WorkoutPlanID(workoutPlanID: UUID()), exercisesDetails: detailedExercises, startDate: workoutStartTime ?? Date(), finishDate: Date())
        return .just(.effect(.workoutFinished(finishedWorkout: finishedWorkout)))
    }
    
    private func handleNonLastEvent() -> Observable<WorkoutExerciseScreenResult> {
        currentEventIndex += 1
        return .merge(checkTypeOfExercise(), .just(.partialState(.updateCurrentEventIndex(currentEventIndex: currentEventIndex))))
    }
}
