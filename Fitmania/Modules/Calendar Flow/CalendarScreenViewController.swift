//
//  CalendarScreenViewController.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 06/06/2023.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class CalendarScreenViewController: BaseViewController, CalendarScreenView, UICollectionViewDelegate {
    typealias ViewState = CalendarScreenViewState
    typealias Effect = CalendarScreenEffect
    typealias Intent = CalendarScreenIntent
    
    @IntentSubject() var intents: Observable<CalendarScreenIntent>
    
    private let effectsSubject = PublishSubject<Effect>()
    private let bag = DisposeBag()
    private let presenter: CalendarScreenPresenter
    
    private var actionSubject = PublishSubject<CalendarScreenIntent>()
    private var pagesActionSubject = PublishSubject<CalendarScreenIntent>()
    
    private lazy var calendarPageViewController = CalendarPageViewController(actionSubject: actionSubject)
    
    private lazy var cardioStackView = UIView()
    
    private lazy var cardioLabel: UILabel = {
        let label = UILabel()
        label.text = "Cardio workout"
        label.textColor = .white
        label.textAlignment = .center
        label.font = .openSansSemiBold12
        return label
    }()
    
    private lazy var cardioBar = UIView(backgroundColor: CalendarCell.cardioWorkoutColor)
    
    private lazy var strengthStackView = UIView()
    
    private lazy var strengthLabel: UILabel = {
        let label = UILabel()
        label.text = "Strength workout"
        label.textColor = .white
        label.textAlignment = .center
        label.font = .openSansSemiBold12
        return label
    }()
    
    private lazy var strengthBar = UIView(backgroundColor: CalendarCell.strengthWorkoutcolor)

    private lazy var colorsLegendStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [cardioStackView, strengthStackView])
        view.axis = .horizontal
        view.distribution = .fillEqually
        return view
    }()
    
    private lazy var contentStackView: UIStackView = {
        let view = UIStackView()
        view.distribution = .fill
        view.axis = .vertical
        view.spacing = 8
        return view
    }()
    
    init(presenter: CalendarScreenPresenter) {
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
        self._intents.subject.onNext(.viewLoaded)
    }
    
    private func layoutView() {
        view.backgroundColor = .primaryColor
        
        calendarPageViewController.willMove(toParent: self)
        guard let pageViewControllerView = calendarPageViewController.view else { return }
        view.addSubview(contentStackView)
        contentStackView.addArrangedSubview(pageViewControllerView)
        contentStackView.addArrangedSubview(colorsLegendStackView)
        calendarPageViewController.didMove(toParent: self)
        
        contentStackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-24)
            $0.left.right.equalToSuperview()
        }
        
        colorsLegendStackView.snp.makeConstraints {
            $0.height.equalTo(24)
        }
        
        cardioStackView.addSubview(cardioLabel)
        cardioStackView.addSubview(cardioBar)
        
        cardioLabel.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.height.equalToSuperview().multipliedBy(0.5)
        }
        
        cardioBar.snp.makeConstraints {
            $0.top.equalTo(cardioLabel.snp.bottom).offset(4)
            $0.bottom.equalToSuperview()
            $0.left.right.equalToSuperview().inset(24)
        }
        
        strengthStackView.addSubview(strengthLabel)
        strengthStackView.addSubview(strengthBar)
        
        strengthLabel.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.height.equalToSuperview().multipliedBy(0.5)
        }
        
        strengthBar.snp.makeConstraints {
            $0.top.equalTo(strengthLabel.snp.bottom).offset(4)
            $0.bottom.equalToSuperview()
            $0.left.right.equalToSuperview().inset(24)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func bindControls() {
        Observable.merge(actionSubject.skip(1), pagesActionSubject)
            .bind(to: _intents.subject)
            .disposed(by: bag)
    }
    
    private func trigger(effect: Effect) {
        switch effect {
        default: break
        }
    }

    func render(state: ViewState) {
        var calendarPages: [CalendarPage] = []
        var calendarMonths = state.calendarMonths
        
        state.calendarMonths.forEach { month in
            let calendarPage = CalendarPage(calendarMonth: month)
            calendarMonths.append(month)
            calendarPages.append(calendarPage)
        }
        
        if state.shouldSetPages && !calendarPages.isEmpty {
            calendarPageViewController.setPages(pages: calendarPages, direction: state.swipeDirection)
        }
        
        if state.shouldReloadCollectionView {
            calendarPageViewController.reloadCollectionViews(calendarMonths: calendarMonths)
        }
    }
}
