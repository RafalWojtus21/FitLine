//
//  PersonalRecordCell.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 07/01/2024.
//

import UIKit
import SnapKit

class PersonalRecordCell: UITableViewCell, ReusableCell {
    
    struct ViewModel {
        let exercise: Exercise
        var exerciseName: String { exercise.name }
        var exerciseCategory: Exercise.Category { exercise.category}
        let bestScore: Float
        let date: Date
    }
    
    // MARK: Properties
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .primaryColor
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.primaryColor.cgColor
        view.layer.cornerRadius = 12
        return view
    }()
    
    private lazy var mainView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [dateLabel, exerciseNameLabel, bestScoreLabel])
        view.axis = .horizontal
        view.backgroundColor = .clear
        view.distribution = .fillProportionally
        view.spacing = 4
        return view
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = .openSansSemiBold14
        label.textColor = .lightGray
        label.textAlignment = .left
        return label
    }()
    
    private lazy var exerciseNameLabel: UILabel = {
        let label = UILabel()
        label.font = .openSansSemiBold16
        label.textColor = .secondaryColor
        label.textAlignment = .left
        return label
    }()
    
    private lazy var bestScoreLabel: UILabel = {
        let label = UILabel()
        label.font = .openSansSemiBold16
        label.textColor = .white
        label.textAlignment = .right
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
        exerciseNameLabel.text = viewModel.exerciseName
        let unit: String = viewModel.exerciseCategory == .cardio ? "km" : "kg"
        bestScoreLabel.text = "\(viewModel.bestScore)" + " " + unit
        let dateFormatter = DateFormatter.dayMonthDateFormatter
        dateLabel.text = dateFormatter.string(from: viewModel.date)
    }
    
    // MARK: Private Implementation
    
    private func layoutViews() {
        backgroundColor = .clear
        
        addSubview(containerView)
        containerView.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(32)
            $0.bottom.top.equalToSuperview().inset(12)
        }
        
        containerView.addSubview(mainView)
        mainView.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(6)
            $0.top.bottom.equalToSuperview()
        }
        
        dateLabel.snp.makeConstraints {
            $0.width.equalTo(42)
        }
    }
}
