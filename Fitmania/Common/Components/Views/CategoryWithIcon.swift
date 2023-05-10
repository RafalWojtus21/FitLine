//
//  CategoryWithIcon.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 10/05/2023.
//

import UIKit
import SnapKit

class CategoryWithIcon: UIView {
    
    // MARK: Properties
    
    private lazy var mainView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [flameIcon, categoryNameLabel])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.backgroundColor = .clear
        return stackView
    }()
    
    private lazy var categoryNameLabel: UILabel = {
        let label = UILabel()
        label.font = .openSansSemiBold20
        label.textColor = .white
        label.textAlignment = .left
        return label
    }()
    
    private lazy var flameIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .systemImageName(.flame)
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    // MARK: Public Implementation
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(categoryName: Exercise.Category) {
        categoryNameLabel.text = categoryName.rawValue.firstLetterCapitalized
    }
    
    // MARK: Private Implementation
    
    private func setupView() {
        addSubview(mainView)
        
        mainView.snp.makeConstraints {
            $0.right.equalToSuperview()
            $0.left.equalToSuperview().inset(16)
            $0.top.bottom.equalToSuperview().inset(4)
        }
        
        flameIcon.snp.makeConstraints {
            $0.width.equalTo(24)
        }
    }
}
