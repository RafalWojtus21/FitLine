//
//  ForgotPasswordScreenViewController.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 09/04/2023.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class ForgotPasswordScreenViewController: BaseViewController, ForgotPasswordScreenView {
    typealias ViewState = ForgotPasswordScreenViewState
    typealias Effect = ForgotPasswordScreenEffect
    typealias Intent = ForgotPasswordScreenIntent
    typealias L = Localization.AuthenticationFlow
    typealias G = Localization.General
    
    @IntentSubject() var intents: Observable<ForgotPasswordScreenIntent>
    
    private let effectsSubject = PublishSubject<Effect>()
    private let bag = DisposeBag()
    private let presenter: ForgotPasswordScreenPresenter
    
    private lazy var screenDescriptionView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [forgotPasswordTitle, subtitle])
        view.axis = .vertical
        view.spacing = 8
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var forgotPasswordTitle: UILabel = {
        let label = UILabel()
        label.text = L.forgotPassword
        label.font = .openSansSemiBold32
        label.textColor = .white
        label.textAlignment = .left
        return label
    }()
    
    private lazy var subtitle: UILabel = {
        let label = UILabel()
        label.text = L.resetInstructions
        label.font = .openSansRegular16
        label.textColor = .white
        label.textAlignment = .left
        return label
    }()
    
    private lazy var emailTextfield: FitmaniaTextField = {
        let fitmaniaTextField = FitmaniaTextField()
        fitmaniaTextField.apply(style: .tertiary, placeholder: L.enterEmail)
        fitmaniaTextField.layer.borderColor = UIColor.white.cgColor
        let textField = fitmaniaTextField.textField
        textField.textContentType = .emailAddress
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        textField.returnKeyType = .next
        return fitmaniaTextField
    }()
    
    private lazy var resetButton: UIButton = {
        let button = UIButton().apply(style: .secondary, title: L.resetPassword)
        button.isEnabled = false
        button.backgroundColor = .secondaryColorDisabled
        return button
    }()
        
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 8.0
        button.clipsToBounds = true
        return button
    }()
    
    private lazy var backButtonImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "arrow.left")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        return imageView
    }()
    
    private lazy var backButtonTitleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textAlignment = .left
        titleLabel.textColor = .white
        return titleLabel
    }()
    
    init(presenter: ForgotPasswordScreenPresenter) {
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
        title = L.resetPassword
        view.backgroundColor = .primaryColor
        navigationItem.setHidesBackButton(true, animated: true)
        view.addSubview(screenDescriptionView)
        view.addSubview(emailTextfield)
        view.addSubview(resetButton)
        view.addSubview(backButton)
        
        screenDescriptionView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).inset(36)
            $0.left.right.equalToSuperview().inset(20)
        }
        
        emailTextfield.snp.makeConstraints {
            $0.top.equalTo(screenDescriptionView.snp.bottom).offset(36)
            $0.left.right.equalToSuperview().inset(8)
        }
        
        resetButton.snp.makeConstraints {
            $0.top.equalTo(emailTextfield.snp.bottom).offset(24)
            $0.height.equalTo(42)
            $0.left.right.equalToSuperview().inset(42)
        }
        
        backButton.snp.makeConstraints {
            $0.top.equalTo(resetButton.snp.bottom).offset(24)
            $0.height.equalTo(42)
            $0.left.right.equalToSuperview().inset(40)
        }
        
        backButton.addSubview(backButtonImage)
        backButton.addSubview(backButtonTitleLabel)

        backButtonTitleLabel.snp.makeConstraints {
            $0.centerX.equalTo(backButton.snp.centerX).offset(10)
            $0.centerY.equalTo(backButton.snp.centerY)
        }
        
        backButtonImage.snp.makeConstraints {
            $0.right.equalTo(backButtonTitleLabel.snp.left).offset(-5)
            $0.top.bottom.equalToSuperview()
            $0.width.equalTo(backButton.snp.width).multipliedBy(0.15)
        }
    }
    
    private func bindControls() {
        let emailValidationIntent = emailTextfield.textField.rx.text.orEmpty.asObservable().skip(3).map { Intent.validateEmail(text: $0) }
        let resetPasswordButtonIntent = resetButton.rx.tap.map { [unowned self] _ -> Intent in
            guard let email = self.emailTextfield.textField.text else { return Intent.invalidCredentials }
            return Intent.resetPasswordIntent(email: email)
        }
        let backToLoginButtonIntent = backButton.rx.tap.map {
            return Intent.backToLoginIntent
        }
        
        Observable.merge(emailValidationIntent, resetPasswordButtonIntent, backToLoginButtonIntent)
            .subscribe(onNext: { [weak self] intent in
                self?._intents.subject.onNext(intent)
            })
            .disposed(by: bag)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    private func trigger(effect: Effect) {
        switch effect {
        case .passwordResetError(error: let error):
            let alert = UIAlertController(title: G.error, message: error, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: G.okMessage, style: .default))
            present(alert, animated: true, completion: nil)
        case .emailSent:
            let alert = UIAlertController(title: "", message: L.emailSentMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: G.okMessage, style: .default))
            present(alert, animated: true, completion: nil)
        default:
            break
        }
    }
    
    func render(state: ViewState) {
        emailTextfield.errorMessage(state.emailValidationMessage.message)
        if state.isResetButtonEnable {
            resetButton.isEnabled = true
            resetButton.backgroundColor = .secondaryColor
        } else {
            resetButton.isEnabled = false
            resetButton.backgroundColor = .secondaryColorDisabled
        }
    }
}
