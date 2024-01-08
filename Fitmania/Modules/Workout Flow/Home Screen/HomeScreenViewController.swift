//
//  HomeScreenViewController.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 19/04/2023.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class HomeScreenViewController: BaseViewController, HomeScreenView {
    typealias ViewState = HomeScreenViewState
    typealias Effect = HomeScreenEffect
    typealias Intent = HomeScreenIntent
    typealias L = Localization.HomeFlow
    
    @IntentSubject() var intents: Observable<HomeScreenIntent>
    
    private let effectsSubject = PublishSubject<Effect>()
    private let bag = DisposeBag()
    private let presenter: HomeScreenPresenter
    
    private var workoutsHistorySubject = PublishSubject<[FinishedWorkout]>()
    private var personalRecordsSubject = PublishSubject<[Exercise: HomeScreen.PersonalRecordData]>()
    
    private lazy var welcomeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 2
        label.font = .openSansSemiBold24
        label.textColor = .tertiaryColor
        return label
    }()
    
    private lazy var workoutsHistoryStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [workoutsHistoryLabelWithIcon, workoutsHistoryTableView])
        view.axis = .vertical
        view.spacing = 8
        return view
    }()
    
    private lazy var workoutsHistoryLabelWithIcon = UIView()
    
    private lazy var workoutsHistoryLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 1
        label.font = .openSansSemiBold16
        label.text = "Last workouts"
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .tertiaryColor
        return label
    }()
    
    private lazy var workoutImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage.systemImageName(.workoutIcon)
        return imageView
    }()
    
    private lazy var workoutsHistoryTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .quaternaryColor.withAlphaComponent(0.2)
        tableView.rowHeight = 80
        tableView.register(WorkoutsHistoryCell.self)
        tableView.layer.cornerRadius = 16
        tableView.showsVerticalScrollIndicator = true
        tableView.indicatorStyle = .white
        return tableView
    }()
    
    private lazy var personalRecordsStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [personalRecordsLabelWithIcon, personalRecordsTableView])
        view.axis = .vertical
        view.spacing = 8
        return view
    }()
    
    private lazy var personalRecordsLabelWithIcon = UIView()

    private lazy var personalRecordsLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 1
        label.font = .openSansSemiBold16
        label.text = "Personal records"
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .tertiaryColor
        return label
    }()
    
    private lazy var personalRecordsImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage.systemImageName(.recordsIcon)
        return imageView
    }()
    
    private lazy var personalRecordsTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .quaternaryColor.withAlphaComponent(0.2)
        tableView.rowHeight = 80
        tableView.register(PersonalRecordCell.self)
        tableView.layer.cornerRadius = 16
        tableView.showsVerticalScrollIndicator = true
        tableView.indicatorStyle = .white
        return tableView
    }()

    private lazy var startWorkoutButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .quaternaryColor
        button.layer.cornerRadius = 8.0
        button.setTitle("Start workout", for: .normal)
        button.titleLabel?.font = .openSansSemiBold20
        button.setTitleColor(.tertiaryColor, for: .normal)
        return button
    }()
    
    init(presenter: HomeScreenPresenter) {
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
        view.backgroundColor = .primaryColor
        view.addSubview(welcomeLabel)
        view.addSubview(workoutsHistoryStackView)
        view.addSubview(personalRecordsStackView)
        view.addSubview(startWorkoutButton)
        
        welcomeLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.left.right.equalToSuperview()
        }
        
        workoutsHistoryStackView.snp.makeConstraints {
            $0.top.equalTo(welcomeLabel.snp.bottom).offset(24)
            $0.left.right.equalToSuperview().inset(32)
        }
        
        workoutsHistoryLabelWithIcon.addSubview(workoutsHistoryLabel)
        workoutsHistoryLabelWithIcon.addSubview(workoutImageView)
        
        workoutsHistoryLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.bottom.equalToSuperview()
        }
        
        workoutImageView.snp.makeConstraints {
            $0.left.equalTo(workoutsHistoryLabel.snp.right).offset(12)
            $0.height.equalToSuperview().multipliedBy(1.6)
            $0.bottom.equalTo(workoutsHistoryLabel.snp.bottom).offset(4)
        }
        
        workoutsHistoryTableView.snp.makeConstraints {
            $0.height.equalTo(view.snp.height).multipliedBy(0.2)
        }
        
        personalRecordsStackView.snp.makeConstraints {
            $0.top.equalTo(workoutsHistoryTableView.snp.bottom).offset(24)
            $0.left.right.equalToSuperview().inset(32)
        }
        
        personalRecordsLabelWithIcon.addSubview(personalRecordsLabel)
        personalRecordsLabelWithIcon.addSubview(personalRecordsImageView)
        
        personalRecordsLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.bottom.equalToSuperview()
        }
        
        personalRecordsImageView.snp.makeConstraints {
            $0.left.equalTo(personalRecordsLabel.snp.right).offset(12)
            $0.height.equalToSuperview().multipliedBy(1.6)
            $0.bottom.equalTo(personalRecordsLabel.snp.bottom).offset(4)
        }
        
        personalRecordsTableView.snp.makeConstraints {
            $0.height.equalTo(view.snp.height).multipliedBy(0.2)
        }
        
        startWorkoutButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-24)
            $0.left.right.equalToSuperview().inset(64)
            $0.height.equalTo(60)
        }
    }
    
    private func bindControls() {
        workoutsHistorySubject
            .bind(to: workoutsHistoryTableView.rx.items(cellIdentifier: WorkoutsHistoryCell.reuseIdentifier, cellType: WorkoutsHistoryCell.self)) { _, item, cell in
                cell.configure(with: WorkoutsHistoryCell.ViewModel(workoutName: item.workoutPlanName, workoutDate: item.startDate, finishDate: item.finishDate))
            }
            .disposed(by: bag)
        
        personalRecordsSubject
            .map { personalRecords in
                personalRecords.sorted { $0.value.date > $1.value.date }
            }
            .bind(to: personalRecordsTableView.rx.items(cellIdentifier: PersonalRecordCell.reuseIdentifier, cellType: PersonalRecordCell.self)) {  _, personalRecord, cell in
                cell.configure(with: .init(exercise: personalRecord.key,
                                           bestScore: personalRecord.value.score,
                                           date: personalRecord.value.date))
            }
            .disposed(by: bag)
        
        let workoutSelectedIntent = workoutsHistoryTableView.rx.modelSelected(FinishedWorkout.self).map {
            return Intent.showWorkoutSummaryIntent(workout: $0)
        }
        
        let startWorkoutIntent = startWorkoutButton.rx.tap.map { Intent.startWorkoutButtonIntent }
        
        Observable.merge(startWorkoutIntent, workoutSelectedIntent)
            .bind(to: _intents.subject)
            .disposed(by: bag)
    }
    
    private func trigger(effect: Effect) {
        switch effect {
        default:
            break
        }
    }
    
    private func configureWelcomeLabel(name: String) -> NSMutableAttributedString {
        let attributedText = NSMutableAttributedString(string: "")
        attributedText.append(NSAttributedString(string: "Let's start training,", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]))
        attributedText.append(NSAttributedString(string: "\n" + name, attributes: [NSAttributedString.Key.foregroundColor: UIColor.tertiaryColor]))
        attributedText.append(NSAttributedString(string: " !", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]))
        return attributedText
    }
    
    func render(state: ViewState) {
        workoutsHistorySubject.onNext(state.workoutsHistory)
        if state.shouldUpdatePersonalRecords {
            personalRecordsSubject.onNext(state.personalRecordsDictionary)
        }
        guard let userName = state.userInfo?.firstName else { return }
        welcomeLabel.attributedText = configureWelcomeLabel(name: userName)
    }
}
