//
//  CategoryExercisesListViewController.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 25/04/2023.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class CategoryExercisesListViewController: BaseViewController, CategoryExercisesListView {
    typealias ViewState = CategoryExercisesListViewState
    typealias Effect = CategoryExercisesListEffect
    typealias Intent = CategoryExercisesListIntent
    
    @IntentSubject() var intents: Observable<CategoryExercisesListIntent>
    
    private let effectsSubject = PublishSubject<Effect>()
    private let bag = DisposeBag()
    private let presenter: CategoryExercisesListPresenter
    
    private var exercisesSubject = PublishSubject<[Exercise]>()

    private var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .white
        tableView.rowHeight = 56
        tableView.register(WorkoutCategoryListCell.self)
        return tableView
    }()
    
    init(presenter: CategoryExercisesListPresenter) {
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
        self._intents.subject.onNext(.viewLoaded)
    }
    
    private func layoutView() {
        view.backgroundColor = .secondaryBackgroundColor
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(16)
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).inset(16)
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).inset(16)
        }
    }
    
    private func bindControls() {
        exercisesSubject
            .bind(to: tableView.rx.items(cellIdentifier: WorkoutCategoryListCell.reuseIdentifier, cellType: WorkoutCategoryListCell.self)) { _, item, cell in
                cell.configureCell(with: WorkoutCategoryListCell.ViewModel(category: item.name))
            }
            .disposed(by: bag)
        
        tableView.rx.modelSelected(Exercise.self)
            .subscribe(onNext: { [weak self] exercise in
                self?._intents.subject.onNext(.cellTapped(chosenExercise: exercise))
            })
            .disposed(by: bag)
    }
    
    private func trigger(effect: Effect) {
        switch effect {
        default:
            break
        }
    }
    
    func render(state: ViewState) {
        exercisesSubject.onNext(state.exercises.sorted(by: { $0.name < $1.name }))
    }
}
