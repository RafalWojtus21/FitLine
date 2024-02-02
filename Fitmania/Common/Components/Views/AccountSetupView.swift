//
//  AccountSetupView.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 10/04/2023.
//

import Foundation

import UIKit
import SnapKit

class AccountSetupView: UIView {
    
    struct Config {
        let keyboardType: UIKeyboardType?
        let placeHolder: String
    }
    
    // MARK: Properties

    private let mainView = UIView(backgroundColor: .clear)

    private lazy var contentView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [leftTextField, rightTextField])
        view.axis = .horizontal
        view.distribution = .fillEqually
        view.spacing = 24
        view.backgroundColor = .clear
        return view
    }()
    
    let leftTextField = FitLineTextField()
    let rightTextField = FitLineTextField()

    // MARK: Public Implementation

    convenience init(leftTextFieldConfig: Config, rightTextFieldConfig: Config) {
        self.init()
        configureTextFields(leftTextFieldConfig: leftTextFieldConfig, rightTextFieldConfig: rightTextFieldConfig)
        setupView()
    }
    
    private func configureTextFields(leftTextFieldConfig: Config, rightTextFieldConfig: Config) {
        leftTextField.apply(config: .init(style: .quaternary, placeHolder: leftTextFieldConfig.placeHolder, keyboardType: leftTextFieldConfig.keyboardType))
        rightTextField.apply(config: .init(style: .quaternary, placeHolder: rightTextFieldConfig.placeHolder, keyboardType: rightTextFieldConfig.keyboardType))
    }
    
    private func setupView() {
        addSubview(mainView)
        mainView.addSubview(contentView)
        
        mainView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(12)
            $0.left.right.equalToSuperview().inset(12)
        }
    }
}
