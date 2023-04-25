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
    typealias ViewState = WorkoutSetupScreenViewState
    typealias Effect = WorkoutSetupScreenEffect
    typealias Intent = WorkoutSetupScreenIntent
    
    @IntentSubject() var intents: Observable<WorkoutSetupScreenIntent>
    
    private let effectsSubject = PublishSubject<Effect>()
    private let bag = DisposeBag()
    private let presenter: WorkoutSetupScreenPresenter
    
    private lazy var addExerciseButton = UIBarButtonItem.init().apply(style: .rightButtonItem, imageName: .plusIcon)

    private lazy var saveButton = UIButton.init().apply(style: .primary, title: "Save training plan")

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
    }
    
    private func layoutView() {
        view.backgroundColor = .secondaryBackgroundColor
        self.navigationItem.rightBarButtonItem = addExerciseButton
        view.addSubview(saveButton)
        
        saveButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(64)
            $0.left.right.equalToSuperview().inset(24)
            $0.height.equalTo(56)
        }
    }
    
    private func bindControls() {
        addExerciseButton.tap
            .subscribe(onNext: {
                self._intents.subject.onNext(.addExerciseButtonIntent)
            })
            .disposed(by: bag)
    }
    
    private func trigger(effect: Effect) {
        switch effect {
        case .showWorkoutsCategoryListScreen:
            break
        }
    }
    
    func render(state: ViewState) {
        self.title = state.trainingName
    }
}
