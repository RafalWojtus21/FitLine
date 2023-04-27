//
//  WorkoutsListScreenViewController.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 20/04/2023.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class WorkoutsListScreenViewController: BaseViewController, WorkoutsListScreenView {
    typealias ViewState = WorkoutsListScreenViewState
    typealias Effect = WorkoutsListScreenEffect
    typealias Intent = WorkoutsListScreenIntent
    typealias L = Localization.HomeFlow
    
    @IntentSubject() var intents: Observable<WorkoutsListScreenIntent>
    
    private let effectsSubject = PublishSubject<Effect>()
    private let bag = DisposeBag()
    private let presenter: WorkoutsListScreenPresenter
    
    private var workoutsSubject = PublishSubject<[WorkoutPlan]>()

    private lazy var plusButton = UIBarButtonItem.init().apply(style: .rightButtonItem, imageName: .plusIcon, title: nil)
    
    private var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .secondaryBackgroundColor
        tableView.separatorStyle = .none
        tableView.rowHeight = 56
        tableView.register(WorkoutsListCell.self)
        return tableView
    }()
    
    init(presenter: WorkoutsListScreenPresenter) {
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
        self._intents.subject.onNext(.loadTrainingPlans)
    }
    
    private func layoutView() {
        view.backgroundColor = .secondaryBackgroundColor
        title = L.workoutsListScreenTitle
        navigationItem.rightBarButtonItem = plusButton
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(32)
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).inset(16)
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).inset(100)
        }
    }
    
    private func bindControls() {
        workoutsSubject
            .bind(to: tableView.rx.items(cellIdentifier: WorkoutsListCell.reuseIdentifier, cellType: WorkoutsListCell.self)) { _, item, cell in
                cell.configureCell(with: WorkoutsListCell.ViewModel(workoutName: item.name))
            }
            .disposed(by: bag)
        
        plusButton?.tap
            .subscribe(onNext: { [weak self] in
                self?._intents.subject.onNext(.plusButtonIntent)
            })
            .disposed(by: bag)
    }
    
    private func trigger(effect: Effect) {
        switch effect {
        case .showWorkoutCategoryListScreen:
            break
        case .nameCustomWorkoutAlert:
            let alert = UIAlertController(title: L.customWorkoutAlertTitle, message: nil, preferredStyle: .alert)
            alert.addTextField { textField in
                textField.placeholder = L.customWorkoutAlertPlaceholder
            }
            alert.addAction(UIAlertAction(title: Localization.General.okMessage, style: .default, handler: { [weak self, weak alert] _ in
                guard let self, let textFieldText = alert?.textFields?.first?.text else { return }
                self._intents.subject.onNext(.createNewTraining(name: textFieldText))
            }))
            self.present(alert, animated: true, completion: nil)
        default: break
        }
    }
    
    func render(state: ViewState) {
        workoutsSubject.onNext(state.workouts)
    }
}
