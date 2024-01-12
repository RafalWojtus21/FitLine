//
//  PersonalDataCell.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 12/01/2024.
//

import UIKit
import SnapKit

class PersonalDataCell: UITableViewCell, ReusableCell {
    
    struct ViewModel {
        var type: UserInfoType
    }
    
    // MARK: Properties
    
    private lazy var containerView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [mainView, arrowImageView])
        view.axis = .horizontal
        view.backgroundColor = .clear
        view.distribution = .fillProportionally
        return view
    }()
    
    private lazy var mainView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [dataTypeLabel, dataValueLabel])
        view.axis = .vertical
        view.backgroundColor = .clear
        view.distribution = .fillEqually
        view.spacing = 4
        return view
    }()
    
    private lazy var dataTypeLabel: UILabel = {
        let label = UILabel()
        label.font = .openSansSemiBold14
        label.textColor = .white
        label.textAlignment = .left
        return label
    }()
    
    private lazy var dataValueLabel: UILabel = {
        let label = UILabel()
        label.font = .openSansRegular16
        label.textColor = .white
        label.textAlignment = .left
        return label
    }()
    
    private lazy var arrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage.systemImageName(.rightArrow)
        imageView.tintColor = .lightGray
        return imageView
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
        let (type, value) = labelAndValue(viewModel)
        dataTypeLabel.text = type
        dataValueLabel.text = value
    }
    
    // MARK: Private Implementation
    
    private func layoutViews() {
        backgroundColor = .clear
        layer.cornerRadius = 12
        
        addSubview(containerView)
        
        containerView.snp.makeConstraints {
            $0.right.top.bottom.equalToSuperview().inset(8)
            $0.left.equalToSuperview().inset(12)
        }
        
        arrowImageView.snp.makeConstraints {
            $0.width.equalTo(16)
        }
    }
    
    private func labelAndValue(_ viewModel: ViewModel) -> (type: String, value: String) {
        switch viewModel.type {
        case .firstName(let string):
            return ("First name", string)
        case .lastName(let string):
            return ("Last name", string)
        case .sex(let sexDataModel):
            return ("Sex", sexDataModel.sex)
        case .age(let int):
            return ("Age", "\(int)")
        case .height(let int):
            return ("Height", "\(int)")
        case .weight(let int):
            return ("Weight", "\(int)")
        }
    }
}
