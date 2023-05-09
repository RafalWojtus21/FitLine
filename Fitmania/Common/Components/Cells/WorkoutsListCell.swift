//
//  WorkoutsListCell.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 27/04/2023.
//

import UIKit
import SnapKit

class WorkoutsListCell: UITableViewCell, ReusableCell {
    
    // MARK: Properties
    
    struct ViewModel {
        let workoutName: String
    }
    
    private lazy var mainView: UIView = {
        let mainView = UIView()
        mainView.backgroundColor = .secondaryBackgroundColor
        mainView.layer.borderWidth = 1
        mainView.layer.borderColor = UIColor.white.cgColor
        mainView.layer.cornerRadius = 8
        return mainView
    }()
    
    private lazy var workoutNameLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .secondaryBackgroundColor
        label.numberOfLines = 0
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.openSansSemiBold14
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

    func configureCell(with viewModel: ViewModel) {
        workoutNameLabel.text = viewModel.workoutName
    }
    
    private func layoutViews() {
        backgroundColor = .clear
        addSubview(mainView)
        mainView.addSubview(workoutNameLabel)
        
        mainView.snp.makeConstraints {
            $0.top.right.left.equalToSuperview()
            $0.bottom.equalToSuperview().inset(5)
        }
        
        workoutNameLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
