//
//  CreateAccountScreenViewController.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 10/04/2023.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class CreateAccountScreenViewController: BaseViewController, CreateAccountScreenView, UITextFieldDelegate {
    typealias ViewState = CreateAccountScreenViewState
    typealias Effect = CreateAccountScreenEffect
    typealias Intent = CreateAccountScreenIntent
    typealias L = Localization.AuthenticationFlow
    
    @IntentSubject() var intents: Observable<CreateAccountScreenIntent>
    
    private let effectsSubject = PublishSubject<Effect>()
    private let bag = DisposeBag()
    private let presenter: CreateAccountScreenPresenter
    
    private var sexSubject = BehaviorSubject<[SexDataModel]>(value: [])
    
    private lazy var accountSetupTitle: UILabel = {
        let label = UILabel()
        label.text = L.accountSetupTitle
        label.font = .openSansSemiBold32
        label.textColor = .white
        label.textAlignment = .left
        return label
    }()
    
    private lazy var namesStackView = AccountSetupView(leftPlaceholder: L.firstName, rightPlacerholder: L.lastName)
    
    private lazy var sexAgeStackView: AccountSetupView = {
        let view = AccountSetupView(leftPlaceholder: L.sex, rightPlacerholder: L.age)
        let textField = view.leftTextField.textField
        textField.inputView = sexPicker
        textField.delegate = self
        return view
    }()
    
    private lazy var heightWeightStackView = AccountSetupView(leftPlaceholder: L.height, rightPlacerholder: L.weight)
    
    private lazy var sexPicker = UIPickerView()
    
    private lazy var accountSetupWithImageStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [personImage, accountSetupView])
        view.axis = .vertical
        view.distribution = .fill
        view.alignment = .center
        view.spacing = 0
        return view
    }()
    
    private lazy var personImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .systemImageName(.personCircleFill)
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = .white
        return imageView
    }()
    
    private lazy var accountSetupView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [namesStackView, firstSeparator, sexAgeStackView, secondSeparator, heightWeightStackView])
        view.axis = .vertical
        view.spacing = 1
        view.backgroundColor = .primaryColor
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 2
        view.layer.cornerRadius = 16
        return view
    }()
    
    private lazy var firstSeparator = UIView(backgroundColor: .white)
    private lazy var secondSeparator = UIView(backgroundColor: .white)
    
    private lazy var createAccountButton = UIButton().apply(style: .primary, title: L.accountSetupButton)
    
    init(presenter: CreateAccountScreenPresenter) {
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
        
        view.addSubview(accountSetupTitle)
        view.addSubview(accountSetupWithImageStackView)
        view.addSubview(createAccountButton)
        
        let stackViewHeight = 110
        
        accountSetupTitle.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(4)
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(24)
            $0.height.equalTo(42)
        }
        
        accountSetupWithImageStackView.snp.makeConstraints {
            $0.top.equalTo(accountSetupTitle.snp.bottom).offset(8)
            $0.left.right.equalToSuperview().inset(16)
        }
        
        accountSetupView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
        }
        
        personImage.snp.makeConstraints {
            $0.height.equalTo(64)
        }
        
        namesStackView.snp.makeConstraints {
            $0.height.equalTo(stackViewHeight)
        }
        
        firstSeparator.snp.makeConstraints {
            $0.height.equalTo(1)
        }
        
        sexAgeStackView.snp.makeConstraints {
            $0.height.equalTo(stackViewHeight)
        }
        
        secondSeparator.snp.makeConstraints {
            $0.height.equalTo(1)
        }
        
        heightWeightStackView.snp.makeConstraints {
            $0.height.equalTo(stackViewHeight)
        }
        
        createAccountButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(64)
            $0.left.right.equalToSuperview().inset(24)
            $0.height.equalTo(56)
        }
    }
    
    private func bindControls() {
        sexSubject.asObservable().bind(to: sexPicker.rx.itemTitles) { _, element in
            self.sexAgeStackView.leftTextField.textField.text = element.sex
            return element.sex
        }
        .disposed(by: bag)
        
        let createAccountIntent = createAccountButton.rx.tap
            .map { [weak self] _ -> Intent in
                guard let self,
                      let firstName = self.namesStackView.leftTextField.textField.text,
                      let lastName = self.namesStackView.rightTextField.textField.text,
                      let sex = self.sexAgeStackView.leftTextField.textField.text,
                      let ageString = self.sexAgeStackView.rightTextField.textField.text,
                      let age = Int(ageString),
                      let heightString = self.heightWeightStackView.leftTextField.textField.text,
                      let height = Int(heightString),
                      let weightString = self.heightWeightStackView.rightTextField.textField.text,
                      let weight = Int(weightString)
                else { return Intent.invalidCredentials }
                let userInfo = UserInfo(firstName: .firstName(firstName), lastName: .lastName(lastName), sex: .sex(.init(sex: sex)), age: .age(age), height: .height(height), weight: .weight(weight))
                return Intent.createAccountButtonIntent(userInfo: userInfo)
            }
        
        let firstNameValidationIntent = namesStackView.leftTextField.textField.rx.text.orEmpty.asObservable().map { Intent.validateName(text: $0) }
        let lastNameValidationIntent = namesStackView.rightTextField.textField.rx.text.orEmpty.asObservable().skip(1).map { Intent.validateLastName(text: $0) }
        let sexValidationIntent = sexAgeStackView.leftTextField.textField.rx.text.orEmpty.asObservable().skip(1).map { Intent.validateSex(text: $0) }
        let ageValidationIntent = sexAgeStackView.rightTextField.textField.rx.text.orEmpty.asObservable().skip(1).map {
            Intent.validateAge(text: $0)
        }
        let heightValidationIntent = heightWeightStackView.leftTextField.textField.rx.text.orEmpty.asObservable().skip(1).map {
            Intent.validateHeight(text: $0)
        }
        let weightValidationIntent = heightWeightStackView.rightTextField.textField.rx.text.orEmpty.asObservable().skip(1).map {
            Intent.validateWeight(text: $0)
        }
        
        Observable.merge(firstNameValidationIntent, lastNameValidationIntent, sexValidationIntent, ageValidationIntent, heightValidationIntent, weightValidationIntent, createAccountIntent)
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
        default:
            break
        }
    }
    
    func render(state: ViewState) {
        sexSubject.onNext(state.sexDataModel)
        namesStackView.leftTextField.errorMessage(state.firstNameValidationMessage.message)
        namesStackView.rightTextField.errorMessage(state.lastNameValidationMessage.message)
        sexAgeStackView.leftTextField.errorMessage(state.sexValidationMessage.message)
        sexAgeStackView.rightTextField.errorMessage(state.ageValidationMessage.message)
        heightWeightStackView.leftTextField.errorMessage(state.heightValidationMessage.message)
        heightWeightStackView.rightTextField.errorMessage(state.weightValidationMessage.message)
        
        if state.isCreateAccountButtonEnable {
            createAccountButton.isEnabled = true
            createAccountButton.backgroundColor = .tertiaryColor
        } else {
            createAccountButton.isEnabled = false
            createAccountButton.backgroundColor = .tertiaryColorDisabled
        }
    }
}
