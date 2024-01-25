//
//  FitmaniaLogo.swift
//  FitLine
//
//  Created by Rafał Wojtuś on 06/04/2023.
//

import UIKit
import SnapKit

class FitLineLogoView: UIView {
    
    // MARK: Properties
    
    private let mainView = UIView(backgroundColor: .clear)
    
    private let fitLineLabel: UILabel = {
        let label = UILabel()
        label.text = Localization.General.fitLine
        label.font = .sfProTextBold52
        label.textColor = .secondaryColor
        label.textAlignment = .center
        return label
    }()
    
    private let line = UIView(backgroundColor: .secondaryColor)
    
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
        mainView.addSubview(fitLineLabel)
        mainView.addSubview(line)
        
        mainView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        fitLineLabel.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.height.equalTo(60)
        }
        
        line.snp.makeConstraints {
            $0.top.equalTo(fitLineLabel.snp.bottom).offset(8)
            $0.height.equalTo(2)
            $0.right.equalToSuperview()
            $0.width.equalTo(90)
        }
    }
}
