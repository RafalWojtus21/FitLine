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
    case tertiary
    case quaternary
}

class FitLineTextField: UIView {
    
    struct Config {
        let style: TextFieldStyle
        let placeHolder: String
        let keyboardType: UIKeyboardType?
    }
    
    // MARK: Properties
    
    private lazy var contentView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [textField, errorLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.distribution = .fill
        return stackView
    }()
    
    lazy var textField: UITextField = {
        let textField = UITextField()
        textField.setLeftPaddingPoints(12)
        return textField
    }()
    
    lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.openSansSemiBold12
        label.textColor = .red
        label.backgroundColor = .clear
        label.text = ""
        return label
    }()
    
    // MARK: Public Implementation
    
    convenience init(style: TextFieldStyle, placeholder: String) {
        self.init()
    }
    
    func apply(config: Config) {
        layoutView(style: config.style)
        configureView(style: config.style, placeholder: config.placeHolder)
        textField.keyboardType = config.keyboardType ?? .default
    }
    
    func errorMessage(_ message: String?) {
        guard let message else {
            errorLabel.text = ""
            return
        }
        errorLabel.text = message
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
        case .secondary:
            textField.snp.makeConstraints {
                $0.height.equalTo(56)
                $0.left.right.equalToSuperview()
            }
        case .tertiary:
            textField.snp.makeConstraints {
                $0.height.equalTo(50)
                $0.left.right.equalToSuperview()
            }
            
            errorLabel.snp.makeConstraints {
                $0.height.equalTo(16)
            }
        case .quaternary:
            errorLabel.snp.makeConstraints {
                $0.height.equalTo(16)
            }
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
            textField.backgroundColor = .primaryColor
            textField.attributedPlaceholder = NSAttributedString(string: placeholder,
                                                       attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
            textField.layer.borderWidth = 1
            textField.layer.borderColor = UIColor.quinaryColor.cgColor
            textField.layer.cornerRadius = 4
            textField.textColor = .quinaryColor
        case .tertiary:
            textField.backgroundColor = .clear
            textField.placeholder = placeholder
            textField.attributedPlaceholder = NSAttributedString(string: placeholder,
                                                                 attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.4)])
            textField.layer.borderColor = UIColor.white.cgColor
            textField.layer.borderWidth = 1
            textField.layer.cornerRadius = 2
            textField.textColor = .quinaryColor
        case .quaternary:
            textField.backgroundColor = .quaternaryColor
            textField.attributedPlaceholder = NSAttributedString(string: placeholder,
                                                       attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
            textField.layer.cornerRadius = 4
            textField.textColor = .white
        }
    }
}
