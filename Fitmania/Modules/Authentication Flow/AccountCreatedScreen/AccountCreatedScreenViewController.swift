//
//  AccountCreatedScreenViewController.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 18/04/2023.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class AccountCreatedScreenViewController: BaseViewController, AccountCreatedScreenView {
    typealias ViewState = AccountCreatedScreenViewState
    typealias Effect = AccountCreatedScreenEffect
    typealias Intent = AccountCreatedScreenIntent
    typealias L = Localization.AuthenticationFlow
    
    @IntentSubject() var intents: Observable<AccountCreatedScreenIntent>
    
    private let effectsSubject = PublishSubject<Effect>()
    private let bag = DisposeBag()
    private let presenter: AccountCreatedScreenPresenter
    
    private lazy var summaryStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [summaryLabel, summarySubtitle])
        view.axis = .vertical
        view.spacing = 16
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var summaryLabel: UILabel = {
        let label = UILabel()
        label.text = L.accountCreatedTitle
        label.font = .openSansSemiBold32
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private lazy var summarySubtitle: UILabel = {
        let label = UILabel()
        label.text = L.accountCreatedSubtitle
        label.font = .openSansRegular16
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private lazy var beginButton = UIButton().apply(style: .primary, title: L.accountCreatedButtonTitle)
    
    init(presenter: AccountCreatedScreenPresenter) {
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
        view.addSubview(summaryStackView)
        view.addSubview(beginButton)
        
        summaryStackView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.right.equalToSuperview().inset(16)
        }
        
        beginButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(64)
            $0.left.right.equalToSuperview().inset(24)
            $0.height.equalTo(56)
        }
    }
    
    private func bindControls() {
        beginButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?._intents.subject.onNext(.beginButtonIntent)
            })
            .disposed(by: bag)
    }
    
    private func trigger(effect: Effect) {
        switch effect {
        default:
            break
        }
    }
    
    func render(state: ViewState) {
    }
}
