//
//  ScheduledNotificationsScreenViewController.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 08/01/2024.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class ScheduledNotificationsScreenViewController: BaseViewController, ScheduledNotificationsScreenView {
    typealias ViewState = ScheduledNotificationsScreenViewState
    typealias Effect = ScheduledNotificationsScreenEffect
    typealias Intent = ScheduledNotificationsScreenIntent
    
    @IntentSubject() var intents: Observable<ScheduledNotificationsScreenIntent>
    
    private let effectsSubject = PublishSubject<Effect>()
    private let bag = DisposeBag()
    private let presenter: ScheduledNotificationsScreenPresenter
    
    private var scheduledTrainingsSubject = PublishSubject<[ScheduledNotificationsScreen.Notification]>()
    
    private lazy var containerStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [scheduledTrainingsTableView])
        view.axis = .horizontal
        return view
    }()

    private lazy var scheduledTrainingsTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
//        tableView.rowHeight = 80
        tableView.register(ScheduledTrainingCell.self)
        tableView.layer.cornerRadius = 16
        tableView.showsVerticalScrollIndicator = true
        tableView.indicatorStyle = .white
        return tableView
    }()
    
    init(presenter: ScheduledNotificationsScreenPresenter) {
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
        title = "Scheduled trainings"
        view.backgroundColor = .primaryColor
        
        view.addSubview(containerStackView)
        
        containerStackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            $0.left.right.equalToSuperview().inset(36)
        }
        
        scheduledTrainingsTableView.snp.makeConstraints {
            $0.height.equalToSuperview()
        }
    }
    
    private func bindControls() {
        scheduledTrainingsSubject
            .bind(to: scheduledTrainingsTableView.rx.items(cellIdentifier: ScheduledTrainingCell.reuseIdentifier, cellType: ScheduledTrainingCell.self)) { _, item, cell in
                cell.configure(with: ScheduledTrainingCell.ViewModel(scheduledTraining: item))
            }
            .disposed(by: bag)
        
        let deleteNotificationIntent = scheduledTrainingsTableView.rx.modelDeleted(ScheduledNotificationsScreen.Notification.self).map {
            return Intent.deletePendingNotification($0.identifier)
        }
        
        Observable.merge(deleteNotificationIntent)
            .subscribe(onNext: { [weak self] intent in
                self?._intents.subject.onNext(intent)
            })
            .disposed(by: bag)
    }
    
    private func trigger(effect: Effect) {
        switch effect {
        case .notificationRequestRemoved:
            print("notification removed")
        }
    }
    
    func render(state: ViewState) {
        scheduledTrainingsSubject.onNext(state.scheduledNotifications)
    }
}
