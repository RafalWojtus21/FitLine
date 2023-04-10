//
//  FitmaniaTextField.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 07/04/2023.
//

import UIKit
import SnapKit

enum TextFieldStyle {
    case primary
    case secondary
}

class FitmaniaTextField: UIView {
    // MARK: Properties
    
    private lazy var contentView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [textField, errorLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()
    
    lazy var textField: UITextField = {
        let textField = UITextField()
        textField.setLeftPaddingPoints(12)
        return textField
    }()
    
    lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.openSansRegular14
        label.textColor = .red
        label.backgroundColor = .clear
        return label
    }()
    
    // MARK: Public Implementation
    
    convenience init(style: TextFieldStyle, placeholder: String) {
        self.init()
    }
    
    func apply(style: TextFieldStyle, placeholder: String) {
        layoutView(style: style)
        configureView(style: style, placeholder: placeholder)
    }
    
    private func layoutView(style: TextFieldStyle) {
        addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        switch style {
        case .primary:
            textField.snp.makeConstraints {
                $0.height.equalTo(56)
                $0.left.right.equalToSuperview()
            }
            
            errorLabel.snp.makeConstraints {
                $0.height.equalTo(16)
            }
        default:
            break
        }
    }
    
    private func configureView(style: TextFieldStyle, placeholder: String) {
        switch style {
        case .primary:
            textField.backgroundColor = .quinaryColor
            textField.placeholder = placeholder
            textField.layer.borderColor = UIColor.black.cgColor
            textField.layer.cornerRadius = 8
            textField.textColor = .black

        case .secondary:
            textField.backgroundColor = .black
            textField.attributedPlaceholder = NSAttributedString(string: placeholder,
                                                       attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
            textField.layer.borderWidth = 1
            textField.layer.borderColor = UIColor.quinaryColor.cgColor
            textField.layer.cornerRadius = 4
            textField.textColor = .lightGray
        }
    }
}
