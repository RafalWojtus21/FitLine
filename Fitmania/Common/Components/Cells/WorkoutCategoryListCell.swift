//
//  WorkoutCategoryListCell.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 25/04/2023.
//

import UIKit
import SnapKit

class WorkoutCategoryListCell: UITableViewCell, ReusableCell {
    // MARK: Properties
    
    struct ViewModel {
        let category: String
    }
    
    private lazy var mainView = UIView(backgroundColor: .secondaryBackgroundColor)
    
    private lazy var categoryLabel: UILabel = {
        let categoryLabel = UILabel()
        categoryLabel.backgroundColor = .clear
        categoryLabel.numberOfLines = 0
        categoryLabel.textColor = .white
        categoryLabel.textAlignment = .left
        categoryLabel.font = UIFont.openSansSemiBold14
        return categoryLabel
    }()
    
    private lazy var arrowImage: UIImageView = {
        let arrowImage = UIImageView()
        arrowImage.image = UIImage.systemImageName(.rightArrow)
        arrowImage.tintColor = .white
        arrowImage.contentMode = .scaleAspectFill
        return arrowImage
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
        categoryLabel.text = viewModel.category
    }
    
    // MARK: Private Implementation
    
    private func layoutViews() {
        backgroundColor = .clear
        addSubview(mainView)
        mainView.addSubview(categoryLabel)
        mainView.addSubview(arrowImage)
        
        mainView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.left.right.bottom.top.equalToSuperview()
        }
        
        arrowImage.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.width.equalTo(10)
            $0.right.equalToSuperview().inset(22)
        }
        
        categoryLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalToSuperview().inset(24)
            $0.height.equalToSuperview().inset(2)
            $0.right.equalTo(arrowImage.snp.left).offset(-16)
        }
    }
}
