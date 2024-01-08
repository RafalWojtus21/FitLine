//
//  ScheduledTrainingCell.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 08/01/2024.
//

import UIKit
import SnapKit

class ScheduledTrainingCell: UITableViewCell, ReusableCell {
    
    struct ViewModel {
        let scheduledTraining: ScheduledNotificationsScreen.Notification
    }
    
    // MARK: Properties
    
    private lazy var containerStackView: UIView = {
        let view = UIStackView(arrangedSubviews: [dateLabel, mainView])
        view.axis = .vertical
        view.backgroundColor = .clear
//        view.layer.cornerRadius = 12
        view.spacing = 6
        return view
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = .openSansSemiBold12
        label.textColor = .lightGray
        label.textAlignment = .left
        return label
    }()
    
    private lazy var mainView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [workoutNameLabel, hourLabel])
        view.axis = .horizontal
        view.backgroundColor = .clear
        view.distribution = .fillProportionally
        view.spacing = 4
        return view
    }()
    
    private lazy var hourLabel: UILabel = {
        let label = UILabel()
        label.font = .openSansSemiBold14
        label.textColor = .white
        label.textAlignment = .right
        return label
    }()
    
    private lazy var workoutNameLabel: UILabel = {
        let label = UILabel()
        label.font = .openSansSemiBold16
        label.textColor = .secondaryColor
        label.textAlignment = .left
        return label
    }()
    
    // MARK: Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        layoutViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Public Implementation

    func configure(with viewModel: ViewModel) {
        workoutNameLabel.text = viewModel.scheduledTraining.title
        guard let date = viewModel.scheduledTraining.scheduledDate else { return }
        let dayMonthateFormatter = DateFormatter.dayMonthStringDateFormatter
        dateLabel.text = dayMonthateFormatter.string(from: date)
        let hourMinuteDateFormatter = DateFormatter.hourMinuteDateFormatter
        hourLabel.text = hourMinuteDateFormatter.string(from: date)
    }
    
    // MARK: Private Implementation
    
    private func layoutViews() {
        backgroundColor = .quaternaryColor.withAlphaComponent(0.2)
        layer.cornerRadius = 12

        addSubview(containerStackView)
        containerStackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(6)
        }
    }
}
