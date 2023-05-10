//
//  WorkoutSetupScreenViewController.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 25/04/2023.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class WorkoutSetupScreenViewController: BaseViewController, WorkoutSetupScreenView {
    typealias L = Localization.CreateWorkoutFlow
    typealias ViewState = WorkoutSetupScreenViewState
    typealias Effect = WorkoutSetupScreenEffect
    typealias Intent = WorkoutSetupScreenIntent
    
    @IntentSubject() var intents: Observable<WorkoutSetupScreenIntent>
    
    private let effectsSubject = PublishSubject<Effect>()
    private let bag = DisposeBag()
    private let presenter: WorkoutSetupScreenPresenter
    
    private var exercisesSubject = PublishSubject<[WorkoutPart]>()
    
    private lazy var addExerciseButton = UIBarButtonItem().apply(style: .rightStringButtonItem, imageName: nil, title: L.addButtonTitle)
    
    private lazy var saveButton = UIButton().apply(style: .primary, title: L.saveButtonTitle)
    
    private var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .primaryColor
        tableView.rowHeight = 80 
        tableView.register(ExerciseDetailsCell.self)
        return tableView
    }()
    
    init(presenter: WorkoutSetupScreenPresenter) {
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
        navigationItem.rightBarButtonItem = addExerciseButton
        
        view.addSubview(tableView)
        view.addSubview(saveButton)
        
        tableView.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(32)
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).inset(16)
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).inset(100)
        }
        
        saveButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(64)
            $0.left.right.equalToSuperview().inset(24)
            $0.height.equalTo(56)
        }
    }
    
    private func bindControls() {
        exercisesSubject
            .bind(to: tableView.rx.items(cellIdentifier: ExerciseDetailsCell.reuseIdentifier, cellType: ExerciseDetailsCell.self)) { _, item, cell in
                cell.configureCell(with: ExerciseDetailsCell.ViewModel(name: item.exercise.name, time: item.time, breakTime: item.breakTime))
            }
            .disposed(by: bag)
        
        let saveButtonIntent = saveButton.rx.tap.map { Intent.saveButtonPressed }
        let addExerciseIntent = addExerciseButton?.tap.map { return Intent.addExerciseButtonIntent }
        guard let addExerciseIntent else { return }
        
        Observable.merge(saveButtonIntent, addExerciseIntent)
            .subscribe(onNext: { [weak self] intent in
                self?._intents.subject.onNext(intent)
            })
            .disposed(by: bag)
    }
    
    private func trigger(effect: Effect) {
        switch effect {
        default: break
        }
    }
    
    func render(state: ViewState) {
        title = state.trainingName
        exercisesSubject.onNext(state.exercises)
    }
}
