//
//  ArrowButton.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 08/01/2024.
//

import UIKit

class SettingsSectionButton: UIButton {
    
    enum ButtonType {
        case normal
        case delete
        case logOut
    }
    
    struct ViewModel {
        let title: String
        let icon: SystemImage
        let buttonType: ButtonType
    }
    
    private lazy var mainView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [iconImageView, buttonTitleLabel, arrowImageView])
        view.distribution = .fillProportionally
        view.axis = .horizontal
        view.spacing = 16
        return view
    }()
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var buttonTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.backgroundColor = .clear
        label.font = .openSansRegular16
        return label
    }()
    
    private lazy var arrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage.systemImageName(.rightArrow)
        imageView.tintColor = .lightGray
        return imageView
    }()
    
    convenience init(viewModel: ViewModel) {
        self.init()
        setTitleLabel(viewModel.title)
        setIcon(viewModel.icon)
        layoutView()
        customize()
        configure(with: viewModel.buttonType)
    }
    
    private func layoutView() {
        addSubview(mainView)
        
        mainView.snp.makeConstraints {
            $0.top.right.bottom.equalToSuperview().inset(4)
            $0.left.equalToSuperview().inset(16)
        }
        
        iconImageView.snp.makeConstraints {
            $0.width.equalTo(24)
        }
        
        arrowImageView.snp.makeConstraints {
            $0.width.equalTo(16)
        }
    }
    
    private func configure(with buttonType: ButtonType) {
        let tintColor: UIColor = switch buttonType {
        case .normal:
                .white
        case .delete:
                .red
        case .logOut:
                .lightBlue
        }
        iconImageView.tintColor = tintColor
        buttonTitleLabel.textColor = tintColor
        arrowImageView.tintColor = tintColor
    }
    
    private func customize() {
        isUserInteractionEnabled = true
        mainView.isUserInteractionEnabled = false
        buttonTitleLabel.isUserInteractionEnabled = false
        arrowImageView.isUserInteractionEnabled = false
        layer.cornerRadius = 8
    }
    
    private func setTitleLabel(_ title: String) {
        buttonTitleLabel.text = title
    }
    
    private func setIcon(_ imageName: SystemImage) {
        iconImageView.image = UIImage.systemImageName(imageName)
    }
}
