//
//  FitmaniaLogo.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 06/04/2023.
//

import UIKit
import SnapKit

class FitmaniaLogoView: UIView {
    // MARK: Properties
    
    private lazy var mainView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var fitmaniaLabel: UILabel = {
        let label = UILabel()
        label.text = "Fitmania"
        label.font = .sfProTextBold52
        label.textColor = .secondaryColor
        label.textAlignment = .center
        return label
    }()
    
    private lazy var line: UIView = {
        let view = UIView()
        view.backgroundColor = .secondaryColor
        return view
    }()
    
    // MARK: Public Implementation
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(mainView)
        mainView.addSubview(fitmaniaLabel)
        mainView.addSubview(line)
        
        mainView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        fitmaniaLabel.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.height.equalTo(60)
        }
        
        line.snp.makeConstraints {
            $0.top.equalTo(fitmaniaLabel.snp.bottom).offset(8)
            $0.height.equalTo(2)
            $0.right.equalToSuperview()
            $0.width.equalTo(90)
        }
    }
}
