//
//  CalendarDayview.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 06/06/2023.
//

import UIKit

class CalendarDaysView: UIView {

    // MARK: Properties
    
    private lazy var mainView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [])
        view.axis = .horizontal
        view.distribution = .fillEqually
        
        let calendar = Calendar.current
        var weekdaySymbols = calendar.weekdaySymbols
        weekdaySymbols.append(weekdaySymbols.removeFirst())
        
        weekdaySymbols.forEach { day in
            view.addArrangedSubview(generateDayLabel(day: day))
        }
        return view
    }()
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Private Implementation
    
    private func layoutViews() {
        addSubview(mainView)
        mainView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func generateDayLabel(day: String) -> UILabel {
        let label = UILabel()
        label.font = .openSansSemiBold12
        label.textColor = .white
        label.textAlignment = .center
        label.text = day
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        return label
    }
}
