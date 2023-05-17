//
//  RegisterScreenViewController.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 06/04/2023.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class RegisterScreenViewController: BaseViewController, RegisterScreenView {
    typealias ViewState = RegisterScreenViewState
    typealias Effect = RegisterScreenEffect
    typealias Intent = RegisterScreenIntent
    typealias L = Localization.AuthenticationFlow
    typealias G = Localization.General
    
    @IntentSubject() var intents: Observable<RegisterScreenIntent>
    
    private let effectsSubject = PublishSubject<Effect>()
    private let bag = DisposeBag()
    private let presenter: RegisterScreenPresenter
    
    private lazy var credentialsStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [emailView, passwordView, repeatPasswordView])
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
    
    private lazy var repeatPasswordView: TextFieldWithTitleView = {
        let fitmaniaTextField = TextFieldWithTitleView(style: .primary, title: L.repeatPassword, placeholder: L.repeatPassword)
        let textField = fitmaniaTextField.fitmaniaTextField.textField
        textField.textContentType = .password
        textField.isSecureTextEntry = true
        textField.keyboardType = .default
        textField.returnKeyType = .done
        return fitmaniaTextField
    }()
    
    private lazy var registerButton: UIButton = {
        let button = UIButton().apply(style: .primary, title: L.register)
        button.isEnabled = false
        return button
    }()
    
    init(presenter: RegisterScreenPresenter) {
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
        title = L.createAccount
        view.backgroundColor = .primaryColor
        
        view.addSubview(credentialsStackView)
        view.addSubview(registerButton)
     
        credentialsStackView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(64)
            $0.left.right.equalToSuperview().inset(8)
        }
        
        registerButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(64)
            $0.left.right.equalToSuperview().inset(24)
            $0.height.equalTo(56)
        }
    }
    
    private func bindControls() {
        let registerButtonIntent = registerButton.rx.tap.map { [weak self] _ -> Intent in
            guard let email = self?.emailView.fitmaniaTextField.textField.text, let password = self?.passwordView.fitmaniaTextField.textField.text else { return Intent.invalidCredentials }
            return Intent.registerButtonIntent(email: email, password: password)
        }
        let emailValidationIntent = emailView.fitmaniaTextField.textField.rx.text.orEmpty.asObservable().skip(3).map { Intent.validateEmail(text: $0) }
        let passwordText = passwordView.fitmaniaTextField.textField.rx.text.orEmpty
        let passwordValidationIntent = passwordText.asObservable().skip(3).map { Intent.validatePassword(text: $0) }
        let repeatPasswordText = repeatPasswordView.fitmaniaTextField.textField.rx.text.orEmpty
        let repeatPasswordValidationIntent = Observable.combineLatest(passwordText.asObservable(), repeatPasswordText.asObservable())
            .map { Intent.validateRepeatPassword(password: $0, repeatPassword: $1) }
        
        Observable.merge(registerButtonIntent, emailValidationIntent, passwordValidationIntent, repeatPasswordValidationIntent)
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
        case .registerError(error: let error):
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
        repeatPasswordView.fitmaniaTextField.errorLabel.text = state.repeatPasswordValidationMessage.message
        registerButton.isEnabled = state.isRegisterButtonEnable
        registerButton.backgroundColor = state.isRegisterButtonEnable ? .tertiaryColor : .tertiaryColorDisabled
    }
}
