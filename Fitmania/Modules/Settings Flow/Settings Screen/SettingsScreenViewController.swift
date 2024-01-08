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
    
    private lazy var accountLabel: UILabel = {
        let label = UILabel()
        label.font = .openSansSemiBold16
        label.text = "Accounts Center"
        label.textColor = .lightGray
        label.textAlignment = .left
        return label
    }()
    
    private lazy var personalDetailsButton = SettingsSectionButton(title: "About", icon: .personCircle)
    
    private lazy var accountStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [accountLabel, personalDetailsButton])
        view.axis = .vertical
        view.spacing = 4
        view.distribution = .fillProportionally
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private lazy var activitiesLabel: UILabel = {
        let label = UILabel()
        label.font = .openSansSemiBold16
        label.text = "Activities"
        label.textColor = .lightGray
        label.textAlignment = .left
        return label
    }()
    
    private lazy var scheduledTrainingsButton = SettingsSectionButton(title: "Scheduled trainings", icon: .bell)
    
    private lazy var activitiesStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [activitiesLabel, scheduledTrainingsButton])
        view.axis = .vertical
        view.spacing = 4
        view.distribution = .fillProportionally
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private lazy var settingsStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [accountStackView, activitiesStackView])
        view.axis = .vertical
        view.spacing = 16
        view.distribution = .fill
        view.isUserInteractionEnabled = true
        return view
    }()
    
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
        let buttonHeight = 36
        let labelHeight = 36
        
        view.backgroundColor = .primaryColor
        view.addSubview(signOutButton)
        view.addSubview(settingsStackView)
        
        signOutButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(24)
            $0.left.right.equalToSuperview().inset(48)
            $0.height.equalTo(48)
        }
        
        settingsStackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(24).priority(.high)
            $0.bottom.equalTo(signOutButton.snp.top).offset(-36).priority(.medium)
            $0.left.right.equalToSuperview().inset(16)
        }
    
        accountLabel.snp.makeConstraints {
            $0.height.equalTo(labelHeight)
        }
        
        personalDetailsButton.snp.makeConstraints {
            $0.height.equalTo(buttonHeight)
            $0.width.equalToSuperview()
        }
        
        activitiesLabel.snp.makeConstraints {
            $0.height.equalTo(labelHeight)
        }
        
        scheduledTrainingsButton.snp.makeConstraints {
            $0.height.equalTo(buttonHeight)
        }
    }
    
    private func bindControls() {
        let signOutButtonIntent = signOutButton.rx.tap.map { Intent.signOutButtonIntent }
        let personalDetailsButtonIntent = personalDetailsButton.rx.tap.map { Intent.personalDetailsButtonIntent }
        let scheduledTrainingsButtonIntent = scheduledTrainingsButton.rx.tap.map { Intent.scheduledTrainingsButtonIntent }

        Observable.merge(signOutButtonIntent, personalDetailsButtonIntent, scheduledTrainingsButtonIntent)
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
