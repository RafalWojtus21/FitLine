//
//  ArrowButton.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 08/01/2024.
//

import UIKit

class SettingsSectionButton: UIButton {
    
    private lazy var mainView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [iconImageView, buttonTitleLabel, arrowImageView])
        view.distribution = .fillProportionally
        view.axis = .horizontal
        view.spacing = 24
        return view
    }()
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = .white
        return imageView
    }()
    
    private lazy var buttonTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.backgroundColor = .clear
        label.textColor = .white
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
    
    convenience init(title: String, icon: SystemImage) {
        self.init()
        setTitleLabel(title)
        setIcon(icon)
        layoutView()
        customize()
    }
    
    private func layoutView() {
        addSubview(mainView)
        
        mainView.snp.makeConstraints {
            $0.top.right.bottom.equalToSuperview().inset(4)
            $0.left.equalToSuperview().inset(24)
        }
        
        iconImageView.snp.makeConstraints {
            $0.width.equalTo(16)
        }
        
        arrowImageView.snp.makeConstraints {
            $0.width.equalTo(24)
        }
    }
    
    private func customize() {
        isUserInteractionEnabled = true
        mainView.isUserInteractionEnabled = false
        buttonTitleLabel.isUserInteractionEnabled = false
        arrowImageView.isUserInteractionEnabled = false
        backgroundColor = .quaternaryColor.withAlphaComponent(0.2)
        layer.cornerRadius = 8
    }
    
    private func setTitleLabel(_ title: String) {
        buttonTitleLabel.text = title
    }
    
    private func setIcon(_ imageName: SystemImage) {
        iconImageView.image = UIImage.systemImageName(imageName)
    }
}
