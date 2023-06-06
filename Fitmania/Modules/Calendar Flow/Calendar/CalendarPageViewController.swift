//
//  CalendarPageViewController.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 07/06/2023.
//

import UIKit
import SnapKit
import RxSwift
import RxRelay

class CalendarPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    struct SwipeInfo {
        var offset: Int
        var swipeDirection: CalendarPageSwipeDirection
    }
    
    // MARK: Properties
    
    private let calendarBag = DisposeBag()
    private var pagesBag = DisposeBag()

    private let actionSubject: PublishSubject<CalendarScreenIntent>
    private var pagesRelay = BehaviorRelay<[CalendarPage]>(value: [])
    
    private var pages: [CalendarPage] {
        pagesRelay.value
    }
    private var arePagesSet = false
    
    private let initialReferencePageIndex = 2
    private var currentPageIndexReference: BehaviorSubject<Int> {
        BehaviorSubject(value: initialReferencePageIndex)
    }
    
    private var currentMonthSwipeInfo = BehaviorRelay<SwipeInfo>(value: SwipeInfo(offset: 0, swipeDirection: .none))
    private var currentOffset = BehaviorRelay<Int>(value: 0)
    
    // MARK: Initialization

    init(actionSubject: PublishSubject<CalendarScreenIntent>) {
        self.actionSubject = actionSubject
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Public Implementation
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
    }
    
    func reloadCollectionViews(calendarMonths: [CalendarMonth]) {
        pages.enumerated().forEach { index, page in
            page.calendarMonth = calendarMonths[index]
            page.reloadCollectionView()
        }
    }
    
    func setPages(pages: [CalendarPage], direction: CalendarPageSwipeDirection) {
        if !pages.isEmpty && !arePagesSet {
            pagesRelay.accept(pages)
            setupInitialSubscriptions()
            arePagesSet = true
            setViewControllers([pages[initialReferencePageIndex]], direction: .forward, animated: false, completion: nil)
        } else if arePagesSet {
            refreshPages(pages: pages, direction: direction)
            setupPagesSubscriptions()
        }
    }
    
    // MARK: Private Implemenetation
    
    private func setupInitialSubscriptions() {
        
        currentMonthSwipeInfo
            .subscribe(onNext: { swipeInfo in
                self.actionSubject.onNext(.reloadDataForOffset(offset: swipeInfo.offset, swipeDirection: swipeInfo.swipeDirection))
            })
            .disposed(by: calendarBag)
        
        setupPagesSubscriptions()
    }
        
    private func setupPagesSubscriptions() {
        pagesBag = .init()
        
        pages.forEach { page in
            subscribeToCalendarPageEvents(for: page, bag: pagesBag)
            subscribeToCalendarIntents(for: page, bag: pagesBag)
        }
    }
    
    private func subscribeToCalendarPageEvents(for page: CalendarPage, bag: DisposeBag) {
        page.calendarPageEventObservable
            .subscribe(onNext: { tappedCell in
                self.actionSubject.onNext(.cellTappedIntent(item: tappedCell))
            })
            .disposed(by: bag)
    }
    
    private func subscribeToCalendarIntents(for page: CalendarPage, bag: DisposeBag) {
        page.calendarIntentObservable
            .subscribe(onNext: { intent in
                switch intent {
                case .nextMonthButtonIntent:
                    self.showNextPage()
                    self.actionSubject.onNext(.nextMonthButtonIntent)
                case .previousMonthButtonIntent:
                    self.showPreviousPage()
                    self.actionSubject.onNext(.previousMonthButtonIntent)
                default:
                    break
                }
            })
            .disposed(by: bag)
    }
    
    private func refreshPages(pages: [CalendarPage], direction: CalendarPageSwipeDirection) {
        switch direction {
        case .backward:
            let updatedPages = [pages[0], self.pages[0], self.pages[1], self.pages[2], pages[4]]
            pagesRelay.accept(updatedPages)
        case .forward:
            let updatedPages = [pages[0], self.pages[2], self.pages[3], self.pages[4], pages[4]]
            pagesRelay.accept(updatedPages)
        default: break
        }
    }
    
    private func showNextPage() {
        guard let currentValue = try? currentPageIndexReference.value() else { return }
        let updatedValue = currentValue + 1
        guard updatedValue < self.pages.count else { return }
        self.pages.forEach { $0.setControlsUserInteraction(isEnabled: false) }
        setViewControllers([pages[updatedValue]], direction: .forward, animated: true) { _ in
            self.pages.forEach { $0.setControlsUserInteraction(isEnabled: true) }
        }
        currentOffset.accept(currentOffset.value + 1)
    }
    
    private func showPreviousPage() {
        guard let currentValue = try? currentPageIndexReference.value() else { return }
        let updatedValue = currentValue - 1
        guard !(updatedValue < 0) else { return }
        self.pages.forEach { $0.setControlsUserInteraction(isEnabled: false) }
        setViewControllers([pages[updatedValue]], direction: .reverse, animated: true) { _ in
            self.pages.forEach { $0.setControlsUserInteraction(isEnabled: true) }
        }
        currentOffset.accept(currentOffset.value - 1)
    }
    
    private func updatePageTrackingInfo(swipeDirection: CalendarPageSwipeDirection) {
        var updatedValue = currentOffset.value
        switch swipeDirection {
        case .backward:
            updatedValue -= 1
        case .forward:
            updatedValue += 1
        default: break
        }
        currentOffset.accept(updatedValue)
        currentMonthSwipeInfo.accept(.init(offset: updatedValue, swipeDirection: swipeDirection))
    }
    
    // MARK: Delegate methods
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        // swiftlint:disable:next force_cast
        guard pages.count > 0, let viewControllerIndex = self.pages.firstIndex(of: viewController as! CalendarPage), viewControllerIndex != 0 else {
            return nil
        }
        return self.pages[viewControllerIndex - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        // swiftlint:disable:next force_cast
        guard pages.count > 0, let viewControllerIndex = self.pages.firstIndex(of: viewController as! CalendarPage), viewControllerIndex < self.pages.count - 1 else { return nil }
        return self.pages[viewControllerIndex + 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard finished else {
            Log.calendar.error("PageViewController - did not finish animating")
            return
        }
        guard completed else {
            Log.calendar.error("PageViewController - transition not completed")
            return
        }
        // swiftlint:disable force_cast
        guard let currentViewcontroller = pageViewController.viewControllers?.first, let currentViewControllerIndex = pages.firstIndex(of: currentViewcontroller as! CalendarPage), let previousViewControllerIndex = pages.firstIndex(of: previousViewControllers[0] as! CalendarPage) else {
            return
        }
        // swiftlint:enable force_cast
        if currentViewControllerIndex < previousViewControllerIndex {
            updatePageTrackingInfo(swipeDirection: .backward)
        } else if currentViewControllerIndex > previousViewControllerIndex {
            updatePageTrackingInfo(swipeDirection: .forward)
        } else {
            Log.calendar.error("PageViewController - Swipe direction error")
        }
    }
}
