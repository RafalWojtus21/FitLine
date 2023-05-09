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
    
    let leftTextField = FitmaniaTextField()
    let rightTextField = FitmaniaTextField()

    // MARK: Public Implementation

    convenience init(leftPlaceholder: String, rightPlacerholder: String) {
        self.init()
        configureTextFields(leftPlaceholder: leftPlaceholder, rightPlacerholder: rightPlacerholder)
        setupView()
    }
    
    private func configureTextFields(leftPlaceholder: String, rightPlacerholder: String) {
        leftTextField.apply(style: .secondary, placeholder: leftPlaceholder)
        rightTextField.apply(style: .secondary, placeholder: rightPlacerholder)
    }
    
    private func setupView() {
        addSubview(mainView)
        mainView.addSubview(contentView)
        
        mainView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(30)
            $0.left.right.equalToSuperview().inset(12)
        }
    }
}
