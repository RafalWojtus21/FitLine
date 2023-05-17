//
//  HomeScreenViewController.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 19/04/2023.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class HomeScreenViewController: BaseViewController, HomeScreenView {
    typealias ViewState = HomeScreenViewState
    typealias Effect = HomeScreenEffect
    typealias Intent = HomeScreenIntent
    typealias L = Localization.HomeFlow
    
    @IntentSubject() var intents: Observable<HomeScreenIntent>
    
    private let effectsSubject = PublishSubject<Effect>()
    private let bag = DisposeBag()
    private let presenter: HomeScreenPresenter
    
    private lazy var plusButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 8.0
        button.clipsToBounds = true
        return button
    }()
    
    private lazy var plusButtonImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.systemImageName(SystemImage.plusIcon)
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .tertiaryColor
        return imageView
    }()
    
    init(presenter: HomeScreenPresenter) {
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
        view.addSubview(plusButton)
        
        plusButton.addSubview(plusButtonImage)
        
        plusButton.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            $0.centerX.equalToSuperview()
            $0.height.width.equalTo(300)
        }
        
        plusButtonImage.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func bindControls() {
        plusButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?._intents.subject.onNext(.plusButtonIntent)
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
