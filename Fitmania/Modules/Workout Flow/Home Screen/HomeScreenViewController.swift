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
    
    private lazy var plusButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 8.0
        button.clipsToBounds = true
        return button
    }()
    
    private lazy var plusButtonImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.systemImageName(SystemImage.plusIcon)
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .tertiaryColor
        return imageView
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.rowHeight = 80
        tableView.register(WorkoutsHistoryCell.self)
        tableView.layer.borderColor = UIColor.tertiaryColor.withAlphaComponent(0.6).cgColor
        tableView.layer.borderWidth = 1
        tableView.layer.cornerRadius = 8
        tableView.showsVerticalScrollIndicator = true
        tableView.indicatorStyle = .white
        return tableView
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
        view.addSubview(plusButton)
        view.addSubview(tableView)
        
        plusButton.addSubview(plusButtonImage)
        
        plusButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.centerX.equalToSuperview()
            $0.height.width.equalTo(200)
        }
        
        plusButtonImage.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(plusButton.snp.bottom).offset(12)
            $0.left.right.equalToSuperview().inset(32)
            $0.height.equalTo(160)
        }
    }
    
    private func bindControls() {
        workoutsHistorySubject
            .bind(to: tableView.rx.items(cellIdentifier: WorkoutsHistoryCell.reuseIdentifier, cellType: WorkoutsHistoryCell.self)) { _, item, cell in
                cell.configure(with: WorkoutsHistoryCell.ViewModel(workoutName: item.workoutPlanName, workoutDate: item.startDate, finishDate: item.finishDate))
            }
            .disposed(by: bag)
        
        let workoutSelectedIntent = tableView.rx.modelSelected(FinishedWorkout.self).map {
            return Intent.showWorkoutSummaryIntent(workout: $0)
        }
        
        let plusButtonIntent = plusButton.rx.tap.map { Intent.plusButtonIntent }

        Observable.merge(plusButtonIntent, workoutSelectedIntent)
            .bind(to: _intents.subject)
            .disposed(by: bag)
    }
    
    private func trigger(effect: Effect) {
        switch effect {
        default:
            break
        }
    }
    
    func render(state: ViewState) {
        workoutsHistorySubject.onNext(state.workoutsHistory)
    }
}
