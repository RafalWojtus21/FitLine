//
//  ScheduleWorkoutScreenViewController.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 10/05/2023.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class ScheduleWorkoutScreenViewController: BaseViewController, ScheduleWorkoutScreenView {
    typealias ViewState = ScheduleWorkoutScreenViewState
    typealias Effect = ScheduleWorkoutScreenEffect
    typealias Intent = ScheduleWorkoutScreenIntent
    typealias L = Localization.TrainingAssistantFlow
    
    @IntentSubject() var intents: Observable<ScheduleWorkoutScreenIntent>
    
    private let effectsSubject = PublishSubject<Effect>()
    private let bag = DisposeBag()
    private let presenter: ScheduleWorkoutScreenPresenter
    
    init(presenter: ScheduleWorkoutScreenPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    private lazy var workoutPreviewButton = WorkoutPreviewButton()
    private lazy var scheduleWorkoutButton = UIButton().apply(style: .quaternary, title: "Schedule notification")
    private lazy var startNowButton = UIButton().apply(style: .primary, title: L.startNowButtonTitle)
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutView()
        bindControls()
        effectsSubject.subscribe(onNext: { [weak self] effect in self?.trigger(effect: effect) })
            .disposed(by: bag)
        presenter.bindIntents(view: self, triggerEffect: effectsSubject)
            .subscribe(onNext: { [weak self] state in self?.render(state: state) })
            .disposed(by: bag)
        _intents.subject.onNext(.viewLoaded)
    }
    
    private func layoutView() {
        view.backgroundColor = .primaryColor
        view.addSubview(workoutPreviewButton)
        view.addSubview(startNowButton)
        view.addSubview(scheduleWorkoutButton)
        
        startNowButton.snp.makeConstraints {
            $0.height.equalTo(56)
            $0.bottom.equalToSuperview().inset(64)
            $0.left.right.equalToSuperview().inset(48)
        }
        
        scheduleWorkoutButton.snp.makeConstraints {
            $0.height.equalTo(48)
            $0.bottom.equalTo(startNowButton.snp.top).offset(-16)
            $0.left.right.equalToSuperview().inset(48)
        }
        
        workoutPreviewButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(64)
            $0.left.right.equalToSuperview().inset(32)
        }
    }
    
    private func bindControls() {
        let startNowButtonIntent = startNowButton.rx.tap.map { Intent.startNowButtonIntent }
        let workoutPreviewIntent = workoutPreviewButton.rx.tap.map { Intent.workoutPreviewTapped }
        let scheduleWorkoutIntent = scheduleWorkoutButton.rx.tap.map { Intent.showDateTimePickerIntent }

        Observable.merge(startNowButtonIntent, workoutPreviewIntent, scheduleWorkoutIntent)
            .bind(to: _intents.subject)
            .disposed(by: bag)
    }
    
    private func trigger(effect: Effect) {
        switch effect {
        case .showDateTimePicker(let workoutName):
            let alertController = UIAlertController(title: workoutName, message: "Remind me about workout at:", preferredStyle: .alert)
            
            let notificationVC = NotificationViewController()
            alertController.setValue(notificationVC, forKey: "contentViewController")
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            let doneAction = UIAlertAction(title: Localization.General.okMessage, style: .default, handler: { [weak self] _ in
                guard let self else { return }
                self._intents.subject.onNext(.scheduleWorkoutIntent(date: notificationVC.datePicker.date))
            })
            
            alertController.addAction(cancelAction)
            alertController.addAction(doneAction)
            present(alertController, animated: true, completion: nil)
        case .workoutScheduled:
            DispatchQueue.main.async {
            let alert = UIAlertController(title: "", message: "Workout reminder scheduled successfully", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default))
                self.present(alert, animated: true, completion: nil)
            }
        case .workoutScheduleError:
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Error", message: "Failed to schedule the reminder.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default))
                self.present(alert, animated: true, completion: nil)
            }
        default:
            break
        }
    }
    
    func render(state: ViewState) {
        title = state.chosenWorkout.name
        workoutPreviewButton.configure(with: WorkoutPreviewButton.ViewModel(workoutName: state.chosenWorkout.name, 
                                                                            workoutTotalTime: state.totalWorkoutTimeInMinutes ?? 0, 
                                                                            numberOfSets: state.totalNumberOfSets ?? 0,
                                                                            categories: state.categories))
    }
}
