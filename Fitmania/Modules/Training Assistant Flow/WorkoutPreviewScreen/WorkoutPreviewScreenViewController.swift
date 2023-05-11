//
//  WorkoutPreviewScreenViewController.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 10/05/2023.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class WorkoutPreviewScreenViewController: BaseViewController, WorkoutPreviewScreenView {
    typealias ViewState = WorkoutPreviewScreenViewState
    typealias Effect = WorkoutPreviewScreenEffect
    typealias Intent = WorkoutPreviewScreenIntent
    
    @IntentSubject() var intents: Observable<WorkoutPreviewScreenIntent>
    
    private let effectsSubject = PublishSubject<Effect>()
    private let bag = DisposeBag()
    private let presenter: WorkoutPreviewScreenPresenter
    
    private var exercisesSubject = PublishSubject<[WorkoutPart]>()

    init(presenter: WorkoutPreviewScreenPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.rowHeight = 120
        tableView.register(WorkoutDetailsPreviewCell.self)
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        layoutView()
        bindControls()
        effectsSubject.subscribe(onNext: { [weak self] effect in self?.trigger(effect: effect) })
            .disposed(by: bag)
        presenter.bindIntents(view: self, triggerEffect: effectsSubject)
            .subscribe(onNext: { [weak self] state in self?.render(state: state) })
            .disposed(by: bag)
    }
    
    private func layoutView() {
        view.backgroundColor = .primaryColor
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(42)
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).inset(16)
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).inset(16)
        }
    }
    
    private func bindControls() {
        exercisesSubject
            .bind(to: tableView.rx.items(cellIdentifier: WorkoutDetailsPreviewCell.reuseIdentifier, cellType: WorkoutDetailsPreviewCell.self)) { _, item, cell in
                cell.configure(with: WorkoutDetailsPreviewCell.ViewModel(exercise: item))
            }
            .disposed(by: bag)
    }
    
    private func trigger(effect: Effect) {
    }
    
    func render(state: ViewState) {
        exercisesSubject.onNext(state.chosenWorkout.parts)
    }
}
