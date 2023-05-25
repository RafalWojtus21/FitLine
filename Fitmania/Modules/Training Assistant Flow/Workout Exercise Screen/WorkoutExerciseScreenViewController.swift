//
//  WorkoutExerciseScreenViewController.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 11/05/2023.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import SwiftUI

final class WorkoutExerciseScreenViewController: BaseViewController, WorkoutExerciseScreenView {
    typealias ViewState = WorkoutExerciseScreenViewState
    typealias Effect = WorkoutExerciseScreenEffect
    typealias Intent = WorkoutExerciseScreenIntent
    typealias L = Localization.TrainingAssistantFlow
    
    @IntentSubject() var intents: Observable<WorkoutExerciseScreenIntent>
    
    private let effectsSubject = PublishSubject<Effect>()
    private let bag = DisposeBag()
    private let presenter: WorkoutExerciseScreenPresenter
    
    private var exerciseTrackerSubject = PublishSubject<[WorkoutExerciseScreen.Row]>()
    private var currentEventIndexSubject = BehaviorSubject<Int>(value: 0)
    @Published var isAnimating = false
    
    private lazy var plusButton = UIBarButtonItem.init().apply(style: .rightStringButtonItemBlack, imageName: nil, title: L.setDetailsButtonTitle)
    
    private lazy var workoutDetailsView: UIView = {
        let view = UIView(backgroundColor: .secondaryColor)
        view.layer.cornerRadius = 20
        return view
    }()
    
    private lazy var workoutDetailsStackView: UIStackView = {
        let filler = UIView()
        let view = UIStackView(arrangedSubviews: [eventNameLabel, exerciseContentView, timerControlView])
        view.axis = .vertical
        view.spacing = 20
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var eventNameLabel: UILabel = {
        let label = UILabel()
        label.font = .openSansSemiBold32
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    private lazy var exerciseContentView = UIView(backgroundColor: .secondaryColor)
    private lazy var circularProgressBar = CircularProgressBarView()
    private var model = StrengthExerciseViewDataModel()
    private lazy var strengthExerciseController = UIHostingController(rootView: StrengthExerciseView(model: model, waveColor: Color(.primaryColor), amplify: 150, backgroundColor: Color(.secondaryColor)))
    private var strengthExerciseView: UIView { strengthExerciseController.view }
    
    private lazy var timeLeftLabel: UILabel = {
        let label = UILabel()
        label.font = .openSansSemiBold32
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private lazy var timerControlView: UIView = {
        let view = UIView(backgroundColor: .clear)
        view.addSubview(pauseButton)
        view.addSubview(resumeButton)
        return view
    }()
    
    private var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.rowHeight = 80
        tableView.register(ExerciseTrackerCell.self)
        tableView.allowsSelection = true
        return tableView
    }()
    
    private lazy var pauseButton: UIButton = {
        let button = UIButton().apply(style: .quaternary, title: L.pauseButtonTitle)
        button.isHidden = true
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1
        return button
    }()
    
    private lazy var resumeButton: UIButton = {
        let button = UIButton().apply(style: .quaternary, title: L.resumeButtonTitle)
        button.isHidden = true
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1
        return button
    }()
    
    private lazy var startButton = UIButton().apply(style: .primary, title: L.startButtonTitle)
    private lazy var nextEventButton: UIButton = {
        let button = UIButton().apply(style: .primary, title: L.nextButtonTitle)
        button.isHidden = true
        return button
    }()
    
    init(presenter: WorkoutExerciseScreenPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
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
        navigationItem.rightBarButtonItem = plusButton
        view.backgroundColor = .primaryColor
        view.addSubview(workoutDetailsView)
        workoutDetailsView.addSubview(workoutDetailsStackView)
        workoutDetailsView.addSubview(tableView)
        exerciseContentView.addSubview(circularProgressBar)
        exerciseContentView.addSubview(strengthExerciseView)
        view.addSubview(startButton)
        view.addSubview(nextEventButton)
        
        nextEventButton.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(48)
            $0.bottom.equalToSuperview().inset(36)
            $0.height.equalTo(48)
        }
        
        startButton.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(48)
            $0.bottom.equalToSuperview().inset(36)
            $0.height.equalTo(48)
        }
        
        workoutDetailsView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.bottom.equalTo(nextEventButton.snp.top).offset(-24)
        }
        
        tableView.snp.makeConstraints {
            $0.bottom.left.right.equalToSuperview()
            $0.height.equalTo(160)
        }
        
        workoutDetailsStackView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.bottom.equalTo(tableView.snp.top).offset(-12)
        }
        
        exerciseContentView.snp.makeConstraints {
            $0.height.equalToSuperview().multipliedBy(0.7)
        }
        
        circularProgressBar.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        strengthExerciseView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
  
        circularProgressBar.addSubview(timeLeftLabel)

        timerControlView.snp.makeConstraints {
            $0.height.equalTo(48)
        }

        timeLeftLabel.snp.makeConstraints {
            $0.center.equalTo(circularProgressBar.snp.center)
            $0.width.equalTo(circularProgressBar.snp.width).inset(12)
        }
        
        pauseButton.snp.makeConstraints {
            $0.height.equalToSuperview()
            $0.left.right.equalToSuperview().inset(48)
        }

        resumeButton.snp.makeConstraints {
            $0.height.equalToSuperview()
            $0.left.right.equalToSuperview().inset(48)
        }
    }
    
    override func viewDidLayoutSubviews() {
        navigationController?.navigationBar.tintColor = .black
    }
    
    private func bindControls() {
        exerciseTrackerSubject
            .bind(to: tableView.rx.items(cellIdentifier: ExerciseTrackerCell.reuseIdentifier, cellType: ExerciseTrackerCell.self)) { _, item, cell in
                cell.configure(with: ExerciseTrackerCell.ViewModel(eventName: item.event.name, exerciseType: item.event.exercise.type, eventType: item.event.type, duration: item.event.duration, isSelected: item.isSelected))
            }
            .disposed(by: bag)
        
        currentEventIndexSubject
            .distinctUntilChanged()
            .skip(1)
            .subscribe(onNext: { [weak self] currentEventIndex in
                guard let self else { return }
                let indexPath = IndexPath(row: currentEventIndex, section: 0)
                self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
            })
            .disposed(by: bag)
        
        let startButtonIntent = startButton.rx.tap.map { Intent.startEventIntent }
        let nextEventButtonIntent = nextEventButton.rx.tap.map {
            self.circularProgressBar.removeAnimation()
            return Intent.nextEventButtonIntent
        }
        let pauseButtonIntent = pauseButton.rx.tap.map { Intent.pauseButtonIntent }
        let resumeButtonIntent = resumeButton.rx.tap.map { Intent.resumeButtonIntent }
        let plusButtonIntent = plusButton?.tap.map { Intent.plusButtonIntent }
        guard let plusButtonIntent else {
            Log.trainingAssistant.debug("plusButtonIntent is nil")
            return
        }
        Observable.merge(startButtonIntent, nextEventButtonIntent, pauseButtonIntent, resumeButtonIntent, plusButtonIntent)
            .bind(to: _intents.subject)
            .disposed(by: bag)
    }
    
    private func trigger(effect: Effect) {
        switch effect {
        case .showExerciseDetailsAlert(detailsTypes: let detailsTypes):
            let alert = UIAlertController(title: L.setDetailsAlertTitle, message: L.setDetailsAlertMessage, preferredStyle: .alert)
            for detailType in detailsTypes {
                alert.addTextField { textField in
                    textField.placeholder = detailType.rawValue
                }
            }
            alert.addAction(UIAlertAction(title: L.saveAlertAction, style: .default, handler: { [weak self, weak alert] _ in
                guard let self, let textFields = alert?.textFields else { return }
                var texts: [String] = []
                for (index, textField) in textFields.enumerated() {
                    texts.append(textField.text ?? "")
                }
                self._intents.subject.onNext(.saveButtonPressed(details: texts))
            }))
            alert.addAction(UIAlertAction(title: L.cancelAlertAction, style: .cancel))
            present(alert, animated: true, completion: nil)
        default: break
        }
    }
    
    func render(state: ViewState) {
        startButton.isHidden = !state.isStartButtonVisible
        nextEventButton.isHidden = !state.isNextButtonVisible
        pauseButton.isHidden = !state.isPauseButtonVisible
        pauseButton.isEnabled = state.isPauseButtonEnabled
        resumeButton.isHidden = !state.isResumeButtonVisible
        resumeButton.isEnabled = state.isResumeButtonEnabled
        pauseButton.backgroundColor = state.isPauseButtonEnabled ? .white : .lightGray.withAlphaComponent(0.5)
        if state.shouldChangeTable {
            exerciseTrackerSubject.onNext(state.workoutEvents)
        }
        currentEventIndexSubject.onNext(state.currentEventIndex)
        if state.shouldChangeEventName {
            eventNameLabel.text = state.workoutEvents[state.currentEventIndex].event.name
        }
        timeLeftLabel.text = "\(state.timeLeft)" + " s"
        circularProgressBar.setProgress(fromValue: state.previousProgress, toValue: state.currentProgress)
        
        plusButton?.isHidden = state.currentEventIndex % 2 == 1 ? false : true
        
        isAnimating = state.shouldTriggerAnimation
        circularProgressBar.isHidden = !state.shouldShowTimer
        strengthExerciseView.isHidden = !state.shouldShowStrengthExerciseAnimation
        
        if state.intervalState != .notStarted {
            if state.shouldShowTimer {
                circularProgressBar.fadeIn()
            } else {
                circularProgressBar.fadeOut()
            }
            
            if state.shouldShowStrengthExerciseAnimation && state.intervalState != .notStarted {
                strengthExerciseView.fadeIn()
            } else {
                strengthExerciseView.fadeOut()
            }
        }

        model.isAnimating = state.shouldTriggerAnimation
    }
}
