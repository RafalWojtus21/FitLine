//
//  CalendarPage.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 07/06/2023.
//

import UIKit
import SnapKit
import RxSwift

class CalendarPage: UIViewController, UICollectionViewDelegate {
    
    // MARK: Properties
    
    private let bag = DisposeBag()
    var calendarMonth: CalendarMonth
    var calendarItemsSubject = BehaviorSubject<[CalendarItem]>(value: [])
    private var calendarPageEventSubject = PublishSubject<CalendarItem>()
    var calendarPageEventObservable: Observable<CalendarItem> { calendarPageEventSubject }
    private var calendarIntentSubject = PublishSubject<CalendarScreenIntent>()
    var calendarIntentObservable: Observable<CalendarScreenIntent> { calendarIntentSubject }
    
    // MARK: UI Components
    
    private lazy var monthControlStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [previousMonthButton, currentMonthAndYearLabel, nextMonthButton])
        view.axis = .horizontal
        view.distribution = .fillProportionally
        return view
    }()
    
    private lazy var previousMonthButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "arrow.left.circle.fill")
        button.setImage(image, for: .normal)
        button.tintColor = .secondaryColor
        return button
    }()
    
    private lazy var currentMonthAndYearLabel: UILabel = {
        let label = UILabel()
        label.font = .openSansSemiBold24
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 1
        label.text = calendarMonth.monthAndYear
        return label
    }()
    
    private lazy var nextMonthButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "arrow.right.circle.fill")
        button.setImage(image, for: .normal)
        button.tintColor = .secondaryColor
        return button
    }()
    
    private lazy var calendarDaysView = CalendarDaysView()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let spacing = 0
        let itemWidth = (Int(self.view.frame.width) / 7)
        layout.itemSize = CGSize(width: itemWidth, height: 100)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = CGFloat(spacing)
        layout.minimumInteritemSpacing = CGFloat(spacing)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(CalendarCell.self)
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    // MARK: Initialization
    
    init(calendarMonth: CalendarMonth) {
        self.calendarMonth = calendarMonth
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutViews()
        bindControls()
        calendarItemsSubject.onNext(calendarMonth.calendarItems)
    }
    
    // MARK: Public Implementation
    
    func reloadCollectionView() {
        calendarItemsSubject.onNext(calendarMonth.calendarItems)
        collectionView.reloadData()
    }
    
    func setControlsUserInteraction(isEnabled: Bool) {
        let controls = [monthControlStackView, previousMonthButton, nextMonthButton, currentMonthAndYearLabel, calendarDaysView, collectionView]
        controls.forEach { $0.isUserInteractionEnabled = isEnabled }
    }
    
    // MARK: Private Implementation
    
    private func bindControls() {
        calendarItemsSubject
            .filter { !$0.isEmpty }
            .distinctUntilChanged()
            .bind(to: collectionView.rx.items(cellIdentifier: CalendarCell.reuseIdentifier, cellType: CalendarCell.self)) { _, item, cell in
                cell.configure(with: CalendarCell.ViewModel(date: item.date, isCurrentMonth: item.isCurrentMonth, workoutsHistory: item.finishedWorkout))
            }
            .disposed(by: bag)
        
        let previousMonthIntent = previousMonthButton.rx.tap.map { CalendarScreenIntent.previousMonthButtonIntent }
        let nextMonthIntent = nextMonthButton.rx.tap.map { CalendarScreenIntent.nextMonthButtonIntent }
        
        Observable.merge(previousMonthIntent, nextMonthIntent)
            .bind(to: calendarIntentSubject)
            .disposed(by: bag)
        
        collectionView.rx.modelSelected(CalendarItem.self)
            .bind(to: calendarPageEventSubject)
            .disposed(by: bag)
    }
    
    private func layoutViews() {
        view.addSubview(monthControlStackView)
        view.addSubview(calendarDaysView)
        view.addSubview(collectionView)
        
        monthControlStackView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.height.equalTo(35)
            $0.left.right.equalToSuperview()
        }
        
        calendarDaysView.snp.makeConstraints {
            $0.top.equalTo(monthControlStackView.snp.bottom).offset(12)
            $0.height.equalTo(25)
            $0.left.right.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.top.equalTo(calendarDaysView.snp.bottom)
            $0.left.right.equalToSuperview()
        }
        collectionView.reloadData()
    }
}
