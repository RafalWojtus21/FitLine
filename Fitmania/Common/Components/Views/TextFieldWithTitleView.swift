//
//  Label+TextFieldFactory.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 06/04/2023.
//

import UIKit

class TextFieldWithTitleView: UIView {
    
    struct Config {
        let style: TextFieldStyle
        let title: String
        let placeHolder: String
        let keyboardType: UIKeyboardType?
    }
    
    // MARK: Properties
    
    private lazy var contentView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [titleLabel, fitLineTextField])
        view.axis = .vertical
        view.spacing = 8
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.openSansRegular14
        label.textColor = UIColor.quinaryColor
        label.backgroundColor = .clear
        return label
    }()
    
    let fitLineTextField = FitLineTextField()
    
    // MARK: Public Implementation
    
    convenience init(config: Config) {
        self.init()
        configureView(style: config.style, title: config.title, placeholder: config.placeHolder)
        fitLineTextField.apply(config: .init(style: config.style, placeHolder: config.placeHolder, keyboardType: config.keyboardType))
    }
    
    private func configureView(style: TextFieldStyle, title: String, placeholder: String) {
        titleLabel.text = title
        addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        switch style {
        case .primary:
            titleLabel.snp.makeConstraints {
                $0.height.equalTo(16)
            }
            
            fitLineTextField.snp.makeConstraints {
                $0.left.right.equalToSuperview()
            }
        default:
            break
        }
    }
}
