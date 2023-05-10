//
//  WorkoutPreview.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 10/05/2023.
//

import UIKit
import SnapKit

class WorkoutPreviewButton: UIButton {
    
    // MARK: Properties
    
    struct ViewModel {
        let workoutName: String
        let workoutTotalTime: Int
        let categories: [Exercise.Category]
    }
    
    private lazy var mainView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [workoutInfoView, separatorView, workoutCategoriesView])
        view.axis = .vertical
        view.distribution = .fill
        view.backgroundColor = .clear
        view.layer.cornerRadius = 24
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 1
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private lazy var workoutInfoView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [workoutNameLabel, workoutTimeLabel])
        view.axis = .vertical
        view.distribution = .fillProportionally
        view.backgroundColor = .clear
        view.spacing = 8
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private lazy var workoutNameLabel: UILabel = {
        let label = UILabel()
        label.font = .openSansSemiBold20
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private lazy var workoutTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .openSansSemiBold16
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private lazy var separatorView = UIView(backgroundColor: .white)
    
    private lazy var workoutCategoriesView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.distribution = .fillEqually
        view.backgroundColor = .clear
        view.spacing = 12
        view.isUserInteractionEnabled = false
        return view
    }()
    
    // MARK: Public Implementation
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with viewModel: ViewModel) {
        workoutNameLabel.text = viewModel.workoutName
        workoutTimeLabel.text = "\(viewModel.workoutTotalTime)" + " min"
        
        let numberOfRows = (viewModel.categories.count + 1) / 2
        for rowIndex in 0 ..< numberOfRows {
            let rowStackView = UIStackView()
            rowStackView.axis = .horizontal
            rowStackView.distribution = .fillEqually
            
            let numberOfElementsInRow = min(2, viewModel.categories.count - rowIndex * 2)
            for elementIndex in 0 ..< numberOfElementsInRow {
                let category = viewModel.categories[rowIndex * 2 + elementIndex]
                let categoryView = CategoryWithIcon()
                categoryView.configure(categoryName: category)
                rowStackView.addArrangedSubview(categoryView)
            }
            workoutCategoriesView.addArrangedSubview(rowStackView)
        }
    }
    
    // MARK: Private Implementation
    
    private func setupView() {
        addSubview(mainView)

        mainView.snp.makeConstraints {
            $0.left.top.right.equalToSuperview()
        }
        
        separatorView.snp.makeConstraints {
            $0.height.equalTo(1)
        }
    }
}
