//
//  WorkoutDetailsPreviewCell.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 11/05/2023.
//

import UIKit
import SnapKit

class ExerciseTrackerCell: UITableViewCell, ReusableCell {
        
    struct ViewModel {
        let eventName: String
        let duration: Int
        let isSelected: Bool
    }
    
    // MARK: Properties
        
    private lazy var mainView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [eventNameLabel, eventDurationLabel])
        view.axis = .vertical
        view.backgroundColor = .primaryColor
        view.distribution = .fillProportionally
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.cornerRadius = 12
        return view
    }()
    
    private lazy var eventNameLabel: UILabel = {
        let label = UILabel()
        label.font = .openSansSemiBold20
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private lazy var eventDurationLabel: UILabel = {
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
        eventNameLabel.text = viewModel.eventName
        eventDurationLabel.text = "\(viewModel.duration)" + " sec"
        updateView(isSelected: viewModel.isSelected)
    }
    
    // MARK: Private Implementation
    
    private func layoutViews() {
        backgroundColor = .clear
        addSubview(mainView)
        
        mainView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.left.right.equalToSuperview().inset(32)
            $0.bottom.equalToSuperview().inset(12)
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
