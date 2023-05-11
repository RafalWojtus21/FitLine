//
//  WorkoutFinishedScreenViewController.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 17/05/2023.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class WorkoutFinishedScreenViewController: BaseViewController, WorkoutFinishedScreenView {
    typealias ViewState = WorkoutFinishedScreenViewState
    typealias Effect = WorkoutFinishedScreenEffect
    typealias Intent = WorkoutFinishedScreenIntent
    typealias L = Localization.TrainingAssistantFlow
    
    @IntentSubject() var intents: Observable<WorkoutFinishedScreenIntent>
    
    private let effectsSubject = PublishSubject<Effect>()
    private let bag = DisposeBag()
    private let presenter: WorkoutFinishedScreenPresenter
    
    private var exerciseNamesSubject = PublishSubject<[String]>()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.openSansSemiBold32
        label.textColor = .secondaryColor
        label.textAlignment = .center
        label.text = L.workoutFinishedScreenTitle
        return label
    }()
    
    private lazy var workoutTimeStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [workoutDayLabel, workoutHoursLabel])
        view.axis = .vertical
        return view
    }()
    
    private lazy var workoutDayLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.openSansSemiBold20
        label.textColor = .lightGray
        label.textAlignment = .center
        return label
    }()
    
    private lazy var workoutHoursLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.openSansSemiBold24
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private lazy var tableViewContainer = UIView(backgroundColor: .clear)

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.layer.cornerRadius = 24
        tableView.layer.borderWidth = 1
        tableView.layer.borderColor = UIColor.secondaryColor.cgColor
        tableView.showsVerticalScrollIndicator = true
        tableView.indicatorStyle = .white
        tableView.rowHeight = 50
        tableView.register(WorkoutSummaryCell.self)
        return tableView
    }()
    
    private lazy var doneButton = UIButton().apply(style: .primary, title: L.doneButtonTitle)

    init(presenter: WorkoutFinishedScreenPresenter) {
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
        navigationItem.setHidesBackButton(true, animated: true)
        view.backgroundColor = .primaryColor
        view.addSubview(titleLabel)
        view.addSubview(workoutTimeStackView)
        view.addSubview(tableViewContainer)
        tableViewContainer.addSubview(tableView)
        view.addSubview(doneButton)
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(40)
        }
        
        workoutTimeStackView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(24)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(80)
        }
        
        doneButton.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(48)
            $0.bottom.equalToSuperview().inset(36)
            $0.height.equalTo(48)
        }
        
        tableView.snp.makeConstraints {
            $0.centerY.equalTo(view.snp.centerY).priority(.low)
            $0.top.greaterThanOrEqualToSuperview()
            $0.bottom.lessThanOrEqualToSuperview()
            $0.height.equalTo(tableView.contentSize.height).priority(.high)
            $0.left.right.equalToSuperview().inset(32)
        }
        
        tableViewContainer.snp.makeConstraints {
            $0.top.equalTo(workoutTimeStackView.snp.bottom).offset(24)
            $0.left.right.equalToSuperview()
            $0.bottom.equalTo(doneButton.snp.top).offset(-24)
        }
    }

    private func bindControls() {
        exerciseNamesSubject
            .bind(to: tableView.rx.items(cellIdentifier: WorkoutSummaryCell.reuseIdentifier, cellType: WorkoutSummaryCell.self)) { _, item, cell in
                cell.configure(with: WorkoutSummaryCell.ViewModel(exerciseName: item))
            }
            .disposed(by: bag)

        let doneButtonIntent = doneButton.rx.tap.map { Intent.doneButtonPressed }
        
        doneButtonIntent
            .bind(to: _intents.subject)
            .disposed(by: bag)
    }
    
    private func trigger(effect: Effect) {
        switch effect {
        default: break
        }
    }
    
    func render(state: ViewState) {
        exerciseNamesSubject.onNext(state.exerciseNames)
        workoutDayLabel.text = state.workoutDayLabelText
        workoutHoursLabel.text = state.workoutHoursLabelText
        doneButton.isEnabled = state.isWorkoutSaved
        doneButton.backgroundColor = state.isWorkoutSaved ? .tertiaryColor : .tertiaryColorDisabled
        
        tableView.snp.updateConstraints {
            $0.height.equalTo(tableView.contentSize.height).priority(.high)
        }
    }
}
