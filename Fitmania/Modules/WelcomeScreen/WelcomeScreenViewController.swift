//
//  WelcomeScreenViewController.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 05/04/2023.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class WelcomeScreenViewController: BaseViewController, WelcomeScreenView {
    typealias ViewState = WelcomeScreenViewState
    typealias Effect = WelcomeScreenEffect
    typealias Intent = WelcomeScreenIntent
    
    @IntentSubject() var intents: Observable<WelcomeScreenIntent>
    
    private let effectsSubject = PublishSubject<Effect>()
    private let bag = DisposeBag()
    private let presenter: WelcomeScreenPresenter
    
    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .assetImageName(.welcomeScreenBackground)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private lazy var fitmaniaLogo = FitmaniaLogoView()
    
    private lazy var loginButton: UIButton = {
        let button = UIButton()
        button.apply(style: .primary, title: "LOGIN")
        button.layer.cornerRadius = 20
        return button
    }()
    
    private lazy var signupButton: UIButton = {
        let button = UIButton()
        button.apply(style: .primary, title: "SIGNUP")
        button.layer.cornerRadius = 20
        return button
    }()
    
    init(presenter: WelcomeScreenPresenter) {
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
        view.addSubview(backgroundImageView)
        view.addSubview(fitmaniaLogo)
        view.addSubview(loginButton)
        view.addSubview(signupButton)
        
        backgroundImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        fitmaniaLogo.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(70)
            $0.top.equalToSuperview().inset(110)
        }
        
        signupButton.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(64)
            $0.height.equalTo(40)
            $0.bottom.equalToSuperview().inset(36)
        }
        
        loginButton.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(64)
            $0.height.equalTo(40)
            $0.bottom.equalTo(signupButton.snp.top).offset(-16)
        }
    }
    
    private func bindControls() {
        let loginButtonIntent = loginButton.rx.tap.map { Intent.loginButtonIntent }
        let signupButtonIntent = signupButton.rx.tap.map { Intent.signupButtonIntent }

        Observable.merge(loginButtonIntent, signupButtonIntent)
            .subscribe(onNext: { [weak self] intent in
                self?._intents.subject.onNext(intent)
            })
            .disposed(by: bag)
    }
    
    private func trigger(effect: Effect) {
        switch effect {
        case .showLoginScreen:
            break
        case .showSignupScreen:
            break
        }
    }
    
    func render(state: ViewState) {
    }
}
