//
//  CalendarCell.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 06/06/2023.
//

import UIKit
import SnapKit

class CalendarCell: UICollectionViewCell, CollectionViewReusableCell {
    
    struct ViewModel {
        let date: Date
        let calendar = Calendar.current
        var dayNumber: Int {
            let dayNumber = calendar.component(.day, from: date)
            return dayNumber
        }
        let isCurrentMonth: Bool
        let workoutsHistory: [FinishedWorkout]?
    }
    
    // MARK: Properties
    
    private lazy var mainView: UIView = {
        let view = UIView(backgroundColor: .clear)
        view.backgroundColor = .quaternaryColor
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 1
        return view
    }()
    
    private lazy var calendarView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [dayLabel, cardioWorkoutBar, strengthWorkoutBar, spacer])
        view.axis = .vertical
        view.backgroundColor = .clear
        view.distribution = .fillEqually
        view.spacing = 8
        return view
    }()
    
    private lazy var cardioWorkoutBar = UIView(backgroundColor: .clear)
    private lazy var strengthWorkoutBar = UIView(backgroundColor: .clear)
    private lazy var spacer = UIView(backgroundColor: .clear)
    
    private lazy var dayLabel: UILabel = {
        let label = UILabel()
        label.font = .openSansSemiBold16
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Public Implementation
    
    func configure(with viewModel: ViewModel) {
        dayLabel.text = "\(viewModel.dayNumber)"
        mainView.backgroundColor = viewModel.isCurrentMonth ? .quaternaryColor : .lightGray
        guard let workoutsHistory = viewModel.workoutsHistory else {
            cardioWorkoutBar.backgroundColor = .clear
            strengthWorkoutBar.backgroundColor = .clear
            return
        }
        let workoutPresence = checkWorkoutsPresence(date: viewModel.date, workoutsHistory: workoutsHistory, calendar: viewModel.calendar)
        cardioWorkoutBar.backgroundColor = workoutPresence.cardio ? .red : .clear
        strengthWorkoutBar.backgroundColor = workoutPresence.strength ? .green : .clear
    }
    
    // MARK: Private Implementation
    
    private func layoutViews() {
        backgroundColor = .clear
        contentView.addSubview(mainView)
        mainView.addSubview(calendarView)
        
        mainView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        calendarView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(12)
            $0.left.right.bottom.equalToSuperview()
        }
    }
    
    private func checkWorkoutsPresence(date: Date, workoutsHistory: [FinishedWorkout], calendar: Calendar) -> (cardio: Bool, strength: Bool) {
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return (cardio: false, strength: false) }
        
        let cardioWorkout = findWorkout(in: workoutsHistory, condition: { $0 == .cardio }, startOfDay: startOfDay, endOfDay: endOfDay)
        let strengthWorkout = findWorkout(in: workoutsHistory, condition: { $0 != .cardio }, startOfDay: startOfDay, endOfDay: endOfDay)
        
        return (cardio: cardioWorkout != nil, strength: strengthWorkout != nil)
    }
    
    private func findWorkout(in workouts: [FinishedWorkout], condition: (Exercise.Category) -> Bool, startOfDay: Date, endOfDay: Date) -> FinishedWorkout? {
        return workouts.first { workout in
            startOfDay <= workout.finishDate && workout.startDate <= endOfDay &&
            workout.exercisesDetails.contains { detail in
                condition(detail.exercise.category)
            }
        }
    }
}
