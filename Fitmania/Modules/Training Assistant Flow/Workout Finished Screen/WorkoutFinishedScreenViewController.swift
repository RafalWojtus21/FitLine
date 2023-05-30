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
    
    private var workoutSummarySubject = PublishSubject<[WorkoutSummaryModel]>()
    
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
    
    private lazy var collectionViewContainer = UIView(backgroundColor: .clear)
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.itemSize = CGSize(width: Int(view.frame.width - 16) / 2, height: 140)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(WorkoutSummaryCollectionViewCell.self)
        collectionView.backgroundColor = .clear
        return collectionView
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
        view.addSubview(collectionViewContainer)
        collectionViewContainer.addSubview(collectionView)
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
        
        collectionView.snp.makeConstraints {
            $0.centerY.equalTo(view.snp.centerY).priority(.low)
            $0.top.greaterThanOrEqualToSuperview().priority(.high)
            $0.bottom.lessThanOrEqualToSuperview().priority(.high)
            $0.height.equalTo(collectionView.collectionViewLayout.collectionViewContentSize.height).priority(.medium)
            $0.left.right.equalToSuperview()
        }
        
        collectionViewContainer.snp.makeConstraints {
            $0.top.equalTo(workoutTimeStackView.snp.bottom).offset(24)
            $0.left.right.equalToSuperview()
            $0.bottom.equalTo(doneButton.snp.top).offset(-24)
        }
    }

    private func bindControls() {
        workoutSummarySubject
            .bind(to: collectionView.rx.items(cellIdentifier: WorkoutSummaryCollectionViewCell.reuseIdentifier, cellType: WorkoutSummaryCollectionViewCell.self)) { _, item, cell in
                cell.configure(with: WorkoutSummaryCollectionViewCell.ViewModel(exerciseName: item.exerciseName, exerciseType: item.exerciseType, numberOfSets: item.setsNumber, maxRepetitions: item.maxRepetitions, totalTime: item.totalTime, maxWeight: item.maxWeight, distance: item.distance))
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
        workoutSummarySubject.onNext(state.workoutSummary)
        workoutDayLabel.text = state.workoutDayLabelText
        workoutHoursLabel.text = state.workoutHoursLabelText
        doneButton.isEnabled = state.isWorkoutSaved
        doneButton.backgroundColor = state.isWorkoutSaved ? .tertiaryColor : .tertiaryColorDisabled
        collectionViewContainer.layoutSubviews()
        collectionViewContainer.layoutIfNeeded()
        collectionView.snp.updateConstraints {
            $0.height.equalTo(collectionView.collectionViewLayout.collectionViewContentSize.height).priority(.medium)
        }
    }
}
