//
//  ExerciseDetailsCell.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 26/04/2023.
//

import UIKit
import SnapKit

class ExerciseDetailsCell: UITableViewCell, ReusableCell {
    typealias L = Localization.General
    
    // MARK: Properties
    
    struct ViewModel {
        let name: String
        let type: Exercise.ExerciseType
        let timeOrSetsValue: Int
        let breakTime: Int
    }
    
    private lazy var mainView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [exerciseNameLabel, detailsView])
        view.backgroundColor = .clear
        view.spacing = 4
        view.axis = .vertical
        view.layoutMargins.bottom = 8
        view.layoutMargins.left = 32
        view.layoutMargins.right = 16
        view.isLayoutMarginsRelativeArrangement = true
        return view
    }()
    
    private lazy var exerciseNameLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.numberOfLines = 0
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.openSansSemiBold14
        return label
    }()
    
    private lazy var detailsView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [exerciseTimeOrSetsStackView, exerciseBreakTimeStackView])
        view.axis = .vertical
        view.backgroundColor = .clear
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.cornerRadius = 8
        return view
    }()
    
    private lazy var exerciseTimeOrSetsStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [exerciseTimeOrSetsHeader, exerciseTimeOrSetsValueLabel])
        view.axis = .horizontal
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var exerciseTimeOrSetsHeader: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.numberOfLines = 0
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.openSansSemiBold14
        return label
    }()
    
    private lazy var exerciseTimeOrSetsValueLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.numberOfLines = 0
        label.textColor = .white
        label.textAlignment = .left
        label.font = UIFont.openSansSemiBold14
        return label
    }()
    
    private lazy var exerciseBreakTimeStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [exerciseBreakTimeHeader, exerciseBreakTimeValueLabel])
        view.axis = .horizontal
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var exerciseBreakTimeHeader: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.text = L.breakTime + ":"
        label.numberOfLines = 0
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.openSansSemiBold14
        return label
    }()
    
    private lazy var exerciseBreakTimeValueLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.numberOfLines = 0
        label.textColor = .white
        label.textAlignment = .left
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
        switch viewModel.type {
        case .strength:
            exerciseTimeOrSetsHeader.text = L.sets + ":"
        case .cardio:
            exerciseTimeOrSetsHeader.text = L.time + ":"
        }
        exerciseNameLabel.text = viewModel.name
        exerciseTimeOrSetsValueLabel.text = "\(viewModel.timeOrSetsValue)"
        exerciseBreakTimeValueLabel.text = "\(viewModel.breakTime)"
    }
    
    private func layoutViews() {
        backgroundColor = .clear
        addSubview(mainView)
        
        mainView.snp.makeConstraints {
            $0.top.right.left.equalToSuperview()
            $0.bottom.equalToSuperview().inset(10)
        }
        
        exerciseNameLabel.snp.makeConstraints {
            $0.height.equalToSuperview().multipliedBy(0.2)
        }
    }
}
