//
//  WorkoutsCategoryListScreenViewController.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 25/04/2023.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class WorkoutsCategoryListScreenViewController: BaseViewController, WorkoutsCategoryListScreenView {
    typealias ViewState = WorkoutsCategoryListScreenViewState
    typealias Effect = WorkoutsCategoryListScreenEffect
    typealias Intent = WorkoutsCategoryListScreenIntent
    
    @IntentSubject() var intents: Observable<WorkoutsCategoryListScreenIntent>
    
    private let effectsSubject = PublishSubject<Effect>()
    private let bag = DisposeBag()
    private let presenter: WorkoutsCategoryListScreenPresenter
    
    private var categorySubject = PublishSubject<[Exercise.Category]>()
    
    private var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .white
        tableView.rowHeight = 56
        tableView.register(WorkoutCategoryListCell.self)
        return tableView
    }()
    
    init(presenter: WorkoutsCategoryListScreenPresenter) {
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
        categorySubject
            .bind(to: tableView.rx.items(cellIdentifier: WorkoutCategoryListCell.reuseIdentifier, cellType: WorkoutCategoryListCell.self)) { _, item, cell in
                cell.configureCell(with: WorkoutCategoryListCell.ViewModel(category: item.rawValue.firstLetterCapitalized))
            }
            .disposed(by: bag)
        
        tableView.rx.modelSelected(Exercise.Category.self)
            .subscribe(onNext: { [weak self] category in
                self?._intents.subject.onNext(.cellTapped(category: category))
            })
            .disposed(by: bag)
    }

    private func trigger(effect: Effect) {
        switch effect {
        default: break
        }
    }
    
    func render(state: ViewState) {
        categorySubject.onNext(state.categories.sorted(by: { $0.rawValue < $1.rawValue }))
    }
}
