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
    
    private lazy var fitLineLogoView = FitLineLogoView()
    
    private lazy var personalDataLabel: UILabel = {
        let label = UILabel()
        label.font = .openSansSemiBold16
        label.text = "Settings and privacy"
        label.textColor = .lightGray
        label.textAlignment = .left
        return label
    }()
    
    private lazy var personalDetailsButton = SettingsSectionButton(viewModel: .init(title: "About", icon: .personCircle, buttonType: .normal))
    
    private lazy var accountStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [personalDataLabel, personalDetailsButton])
        view.axis = .vertical
        view.spacing = 8
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
    
    private lazy var scheduledTrainingsButton = SettingsSectionButton(viewModel: .init(title: "Scheduled trainings", icon: .bell, buttonType: .normal))
    
    private lazy var activitiesStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [activitiesLabel, scheduledTrainingsButton])
        view.axis = .vertical
        view.spacing = 8
        view.distribution = .fillProportionally
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private lazy var accountCenterLabel: UILabel = {
        let label = UILabel()
        label.font = .openSansSemiBold16
        label.text = "Account Center"
        label.textColor = .lightGray
        label.textAlignment = .left
        return label
    }()
    
    private lazy var deleteAccountButton = SettingsSectionButton(viewModel: .init(title: "Delete account", icon: .trashIcon, buttonType: .delete))
    private lazy var signOutButton = SettingsSectionButton(viewModel: .init(title: "Sign out", icon: .signOut, buttonType: .logOut))
    
    private lazy var accountCenterStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [accountCenterLabel, signOutButton, deleteAccountButton])
        view.axis = .vertical
        view.spacing = 8
        view.distribution = .fillProportionally
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private lazy var settingsStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [accountStackView, activitiesStackView, accountCenterStackView])
        view.axis = .vertical
        view.spacing = 32
        view.distribution = .fill
        view.isUserInteractionEnabled = true
        return view
    }()
            
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
        view.addSubview(fitLineLogoView)
        view.addSubview(settingsStackView)

        fitLineLogoView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(12).priority(.high)
            $0.height.equalTo(36)
            $0.left.right.equalToSuperview().inset(70)
        }
        
        settingsStackView.snp.makeConstraints {
            $0.top.equalTo(fitLineLogoView.snp.bottom).offset(48).priority(.high)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-36).priority(.medium)
            $0.left.right.equalToSuperview().inset(16)
        }
    
        personalDataLabel.snp.makeConstraints {
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
        
        accountCenterLabel.snp.makeConstraints {
            $0.height.equalTo(labelHeight)
        }
        
        deleteAccountButton.snp.makeConstraints {
            $0.height.equalTo(buttonHeight)
        }
        
        signOutButton.snp.makeConstraints {
            $0.height.equalTo(buttonHeight)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func bindControls() {
        let signOutButtonIntent = signOutButton.rx.tap.map { Intent.signOutButtonIntent }
        let personalDetailsButtonIntent = personalDetailsButton.rx.tap.map { Intent.personalDetailsButtonIntent }
        let scheduledTrainingsButtonIntent = scheduledTrainingsButton.rx.tap.map { Intent.scheduledTrainingsButtonIntent }
        let deleteAccountButtonIntent = deleteAccountButton.rx.tap.map { Intent.showDeleteAccountAlert }

        Observable.merge(signOutButtonIntent, personalDetailsButtonIntent, scheduledTrainingsButtonIntent, deleteAccountButtonIntent)
            .bind(to: _intents.subject)
            .disposed(by: bag)
    }
    
    private func trigger(effect: Effect) {
        switch effect {
        case .signOutErrorAlert(error: let error):
            let alert = UIAlertController(title: G.error, message: error, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: G.okMessage, style: .default))
            present(alert, animated: true, completion: nil)
        case .showDeleteAccountWarning:
            let alert = UIAlertController(title: "Warning", message: "Are you sure you want to delete your account? This action cannot be reverted", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .destructive) { _ in
                self._intents.subject.onNext(.deleteAccountButtonIntent)
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alert, animated: true, completion: nil)
        default:
            break
        }
    }
    
    func render(state: ViewState) {
    }
}
