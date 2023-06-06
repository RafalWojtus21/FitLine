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
        view.addSubview(pageViewControllerView)
        calendarPageViewController.didMove(toParent: self)
        
        pageViewControllerView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            $0.left.right.equalToSuperview()
        }
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
