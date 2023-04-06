//
//  Label+TextFieldFactory.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 06/04/2023.
//

import UIKit

class TextFieldWithTitleView: UIView {
    // MARK: Properties
    
    private lazy var contentView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [titleLabel, fitmaniaTextField])
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
    
    let fitmaniaTextField = FitmaniaTextField()
    
    // MARK: Public Implementation
    
    convenience init(style: TextFieldStyle, title: String, placeholder: String) {
        self.init()
        configureView(style: style, title: title, placeholder: placeholder)
        fitmaniaTextField.apply(style: style, placeholder: placeholder)
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
            
            fitmaniaTextField.snp.makeConstraints {
                $0.left.right.equalToSuperview()
            }
        default:
            break
        }
    }
}
