//
//  WorkoutDetailsPreviewCell.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 11/05/2023.
//

import UIKit
import SnapKit

class WorkoutDetailsPreviewCell: UITableViewCell, ReusableCell {
        
    struct ViewModel {
        let exercise: WorkoutPart
    }
    
    // MARK: Properties
    
    private lazy var mainView = UIView(backgroundColor: .clear)
    
    private lazy var exerciseStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [exerciseNameLabel, exerciseTimeLabel])
        view.axis = .vertical
        view.spacing = 2
        view.backgroundColor = .clear
        view.distribution = .fillProportionally
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.cornerRadius = 12
        return view
    }()
    
    private lazy var exerciseNameLabel: UILabel = {
        let label = UILabel()
        label.font = .openSansSemiBold20
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private lazy var exerciseTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .openSansSemiBold16
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private lazy var exerciseBreakTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .openSansSemiBold16
        label.backgroundColor = .secondaryColor
        label.textColor = .black
        label.textAlignment = .center
        label.layer.cornerRadius = 12
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
        exerciseNameLabel.text = viewModel.exercise.exercise.name
        exerciseTimeLabel.text = "\(viewModel.exercise.time)" + " sec"
        exerciseBreakTimeLabel.text = "\(viewModel.exercise.breakTime)" + " sec"
    }
    
    // MARK: Private Implementation
    
    private func layoutViews() {
        backgroundColor = .clear
        
        addSubview(mainView)
        mainView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.bottom.equalToSuperview().inset(32)
        }
        
        mainView.addSubview(exerciseStackView)
        mainView.addSubview(exerciseBreakTimeLabel)
        
        exerciseStackView.snp.makeConstraints {
            $0.height.equalToSuperview().multipliedBy(0.8)
            $0.left.right.top.equalToSuperview()
        }
        
        exerciseBreakTimeLabel.snp.makeConstraints {
            $0.top.equalTo(exerciseStackView.snp.bottom)
            $0.height.equalToSuperview().multipliedBy(0.2)
            $0.left.right.equalToSuperview().inset(24)
        }
    }
}
