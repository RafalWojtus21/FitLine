//
//  SettingsScreenViewController.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 29/05/2023.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class SettingsScreenViewController: BaseViewController, SettingsScreenView {
    typealias ViewState = SettingsScreenViewState
    typealias Effect = SettingsScreenEffect
    typealias Intent = SettingsScreenIntent
    typealias L = Localization.SettingsFlow
    typealias G = Localization.General
    
    @IntentSubject() var intents: Observable<SettingsScreenIntent>
    
    private let effectsSubject = PublishSubject<Effect>()
    private let bag = DisposeBag()
    private let presenter: SettingsScreenPresenter
    
    private lazy var signOutButton = UIButton().apply(style: .primary, title: L.signOutButtonTitle)
    
    init(presenter: SettingsScreenPresenter) {
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
        view.backgroundColor = .primaryColor
        
        view.addSubview(signOutButton)
        
        signOutButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(24)
            $0.left.right.equalToSuperview().inset(48)
            $0.height.equalTo(48)
        }
    }
    
    private func bindControls() {
        let signOutButtonIntent = signOutButton.rx.tap.map { Intent.signOutButtonIntent }
        Observable.merge(signOutButtonIntent)
            .bind(to: _intents.subject)
            .disposed(by: bag)
    }
    
    private func trigger(effect: Effect) {
        switch effect {
        case .signOutErrorAlert(error: let error):
            let alert = UIAlertController(title: G.error, message: error, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: G.okMessage, style: .default))
            present(alert, animated: true, completion: nil)
        default:
            break
        }
    }
    
    func render(state: ViewState) {
    }
}
