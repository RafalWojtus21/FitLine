//
//  WorkoutSummaryCell.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 17/05/2023.
//

import UIKit
import SnapKit

class WorkoutSummaryCell: UITableViewCell, ReusableCell {
        
    struct ViewModel {
        let exerciseName: String
    }
    
    // MARK: Properties

    private lazy var exerciseNameLabel: UILabel = {
        let label = UILabel()
        label.font = .openSansSemiBold20
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
        exerciseNameLabel.text = viewModel.exerciseName
    }
    
    // MARK: Private Implementation
    
    private func layoutViews() {
        backgroundColor = .clear
        addSubview(exerciseNameLabel)
        
        exerciseNameLabel.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.bottom.top.equalToSuperview().inset(8)
        }
    }
}
