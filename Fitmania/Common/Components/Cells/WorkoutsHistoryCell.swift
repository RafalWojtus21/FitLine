//
//  WorkoutsHistoryCell.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 19/05/2023.
//

import UIKit
import SnapKit

class WorkoutsHistoryCell: UITableViewCell, ReusableCell {
    typealias L = Localization.HomeFlow
    
    struct ViewModel {
        let workoutName: String
        let workoutDate: Date
        let finishDate: Date
        var duration: Int { finishDate.minutes(from: workoutDate) }
    }
    
    // MARK: Properties
        
    private lazy var mainView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [workoutNameLabel, workoutDateLabel])
        view.axis = .vertical
        view.backgroundColor = .primaryColor
        view.distribution = .fillProportionally
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.cornerRadius = 12
        return view
    }()
    
    private lazy var workoutNameLabel: UILabel = {
        let label = UILabel()
        label.font = .openSansSemiBold20
        label.textColor = .secondaryColor
        label.textAlignment = .center
        return label
    }()
    
    private lazy var workoutDateLabel: UILabel = {
        let label = UILabel()
        label.font = .openSansSemiBold16
        label.textColor = .white
        label.textAlignment = .center
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
        workoutNameLabel.text = viewModel.workoutName
        let duration = Int(ceil(Double(viewModel.duration)))
        let dateFormatter = DateFormatter.dayMonthHourMinuteDateFormatter
        workoutDateLabel.text = "\(dateFormatter.string(from: viewModel.workoutDate)) - \(duration) " + L.minShortcut
    }
    
    // MARK: Private Implementation
    
    private func layoutViews() {
        backgroundColor = .clear
        addSubview(mainView)
        
        mainView.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(32)
            $0.bottom.top.equalToSuperview().inset(12)
        }
    }
    
    private func updateView(isSelected: Bool) {
        if isSelected {
            mainView.layer.borderColor = UIColor.green.cgColor
            mainView.layer.borderWidth = 5
        } else {
            mainView.layer.borderColor = nil
            mainView.layer.borderWidth = 0
        }
    }
}
