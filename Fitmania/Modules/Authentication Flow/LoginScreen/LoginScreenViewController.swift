//
//  LoginScreenViewController.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 07/04/2023.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class LoginScreenViewController: BaseViewController, LoginScreenView {
    typealias ViewState = LoginScreenViewState
    typealias Effect = LoginScreenEffect
    typealias Intent = LoginScreenIntent
    typealias L = Localization.AuthenticationFlow
    typealias G = Localization.General
    
    @IntentSubject() var intents: Observable<LoginScreenIntent>
    
    private let effectsSubject = PublishSubject<Effect>()
    private let bag = DisposeBag()
    private let presenter: LoginScreenPresenter
    
    private lazy var screenDescriptionView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [loginTitle, loginSubtitle])
        view.axis = .vertical
        view.spacing = 8
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var loginTitle: UILabel = {
        let label = UILabel()
        label.text = L.login
        label.font = .openSansSemiBold32
        label.textColor = .white
        label.textAlignment = .left
        return label
    }()
    
    private lazy var loginSubtitle: UILabel = {
        let label = UILabel()
        label.text = L.loginScreenSubtitle
        label.font = .openSansRegular16
        label.textColor = .white
        label.textAlignment = .left
        return label
    }()
    
    private lazy var credentialsStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [emailView, passwordView, forgotPasswordButton])
        view.axis = .vertical
        view.spacing = 8
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var emailView: TextFieldWithTitleView = {
        let fitmaniaTextField = TextFieldWithTitleView(style: .primary, title: G.email, placeholder: G.email)
        let textField = fitmaniaTextField.fitmaniaTextField.textField
        textField.textContentType = .emailAddress
        textField.keyboardType = .emailAddress
        textField.returnKeyType = .next
        return fitmaniaTextField
    }()
    
    private lazy var passwordView: TextFieldWithTitleView = {
        let fitmaniaTextField = TextFieldWithTitleView(style: .primary, title: G.password, placeholder: G.password)
        let textField = fitmaniaTextField.fitmaniaTextField.textField
        textField.textContentType = .password
        textField.isSecureTextEntry = true
        textField.keyboardType = .default
        textField.returnKeyType = .next
        return fitmaniaTextField
    }()
    
    private lazy var forgotPasswordButton = UIButton().apply(style: .tertiary, title: L.forgotPassword)
    
    private lazy var loginButton: UIButton = {
        let button = UIButton().apply(style: .primary, title: L.login)
        button.isEnabled = false
        return button
    }()
    
    private lazy var createAccountButton = UIButton().apply(style: .tertiary, title: L.noAccountButton)
    
    init(presenter: LoginScreenPresenter) {
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
        view.addSubview(screenDescriptionView)
        view.addSubview(credentialsStackView)
        view.addSubview(loginButton)
        view.addSubview(createAccountButton)
        
        screenDescriptionView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).inset(24)
            $0.left.right.equalToSuperview().inset(20)
        }
        
        loginTitle.snp.makeConstraints {
            $0.height.equalTo(40)
        }
        
        loginSubtitle.snp.makeConstraints {
            $0.height.equalTo(40)
        }
        
        credentialsStackView.snp.makeConstraints {
            $0.top.equalTo(screenDescriptionView.snp.bottom).offset(64)
            $0.left.right.equalToSuperview().inset(8)
        }
        
        createAccountButton.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(8)
            $0.height.equalTo(24)
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).inset(8)
        }
        
        loginButton.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(56)
            $0.height.equalTo(58)
            $0.top.equalTo(credentialsStackView.snp.bottom).offset(64)
        }
    }
    
    private func bindControls() {
        let loginButtonIntent = loginButton.rx.tap.map { [weak self] _ -> Intent in
            guard let email = self?.emailView.fitmaniaTextField.textField.text, let password = self?.passwordView.fitmaniaTextField.textField.text else { return Intent.invalidCredentials }
            return Intent.loginButtonIntent(email: email, password: password)
        }
        let forgotPasswordButtonIntent = forgotPasswordButton.rx.tap.map { Intent.forgotPasswordButtonIntent }
        let createAccountButtonIntent = createAccountButton.rx.tap.map { Intent.createAccountButtonIntent }
        
        let emailValidationIntent = emailView.fitmaniaTextField.textField.rx.text.orEmpty.asObservable().skip(3).map { Intent.validateEmail(text: $0) }
        let passwordValidationIntent = passwordView.fitmaniaTextField.textField.rx.text.orEmpty.asObservable().skip(3).map { Intent.validatePassword(text: $0) }
        
        Observable.merge(loginButtonIntent, forgotPasswordButtonIntent, createAccountButtonIntent, emailValidationIntent, passwordValidationIntent)
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
        case .wrongCredentialsAlert(error: let error):
            let alert = UIAlertController(title: G.error, message: error, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: G.okMessage, style: .default))
            present(alert, animated: true, completion: nil)
        default:
            break
        }
    }
    
    func render(state: ViewState) {
        emailView.fitmaniaTextField.errorLabel.text = state.emailValidationMessage.message
        passwordView.fitmaniaTextField.errorLabel.text = state.passwordValidationMessage.message
        loginButton.isEnabled = state.isLoginButtonEnable
        loginButton.backgroundColor = state.isLoginButtonEnable ? .tertiaryColor : .tertiaryColorDisabled
    }
}
