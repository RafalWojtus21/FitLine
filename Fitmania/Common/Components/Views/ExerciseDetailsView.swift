//
//  ExerciseDetailsView.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 25/04/2023.
//

import UIKit
import SnapKit

class ExerciseDetailsView: UIView {
    typealias L = Localization.CreateWorkoutFlow
    
    struct ViewModel {
        let category: Exercise.Category
    }
    
    // MARK: Properties
    
    private lazy var mainView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.distribution = .fillEqually
        view.backgroundColor = .clear
        view.layer.cornerRadius = 8
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 1
        return view
    }()
    
    private let setsView = UIView(backgroundColor: .clear)
    
    private let setsLabel: UILabel = {
        let label = UILabel()
        label.text = "Sets"
        label.font = .openSansSemiBold14
        label.textColor = .white
        return label
    }()
    
    let setsTextfield: UITextField = {
        let textField = UITextField()
        textField.textAlignment = .right
        textField.setRightPaddingPoints(12)
        textField.setPlaceholder(placeholder: L.setTimeMessage, textColor: .lightGray)
        textField.textColor = .white
        textField.keyboardType = .numberPad
        textField.returnKeyType = .next
        return textField
    }()
    
    private let timeView = UIView(backgroundColor: .clear)
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.text = L.timeWithUnitLabelTitle
        label.font = .openSansSemiBold14
        label.textColor = .white
        return label
    }()
    
    let timeTextField: UITextField = {
        let textField = UITextField()
        textField.textAlignment = .right
        textField.setRightPaddingPoints(12)
        textField.setPlaceholder(placeholder: L.setTimeMessage, textColor: .lightGray)
        textField.textColor = .white
        textField.keyboardType = .numberPad
        textField.returnKeyType = .next
        return textField
    }()
    
    private let breakTimeView = UIView(backgroundColor: .clear)
    
    private let breakTimeLabel: UILabel = {
        let label = UILabel()
        label.text = L.breakTimeWithUnitLabelTitle
        label.font = .openSansSemiBold14
        label.textColor = .white
        return label
    }()
    
    let breakTimeTextField: UITextField = {
        let textField = UITextField()
        textField.textAlignment = .right
        textField.setPlaceholder(placeholder: L.setBreakTimeMessage, textColor: .lightGray)
        textField.setRightPaddingPoints(12)
        textField.textColor = .white
        textField.keyboardType = .numberPad
        textField.returnKeyType = .next
        return textField
    }()
    
    // MARK: Public Implementation
    
    convenience init(with viewModel: ViewModel) {
        self.init()
    }
    
    func setupView(exerciseType: Exercise.ExerciseType) {
        addSubview(mainView)
        
        mainView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        mainView.addArrangedSubview(setsView)
        setsView.addSubview(setsLabel)
        setsView.addSubview(setsTextfield)
        
        setsLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.left.equalToSuperview().inset(16)
        }
        
        setsTextfield.snp.makeConstraints {
            $0.top.bottom.right.equalToSuperview()
            $0.left.equalTo(setsLabel.snp.right).offset(20)
        }
        
        mainView.addArrangedSubview(timeView)
        timeView.addSubview(timeLabel)
        timeView.addSubview(timeTextField)
        
        mainView.addArrangedSubview(breakTimeView)
        
        timeLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.left.equalToSuperview().inset(16)
        }
        
        timeTextField.snp.makeConstraints {
            $0.top.bottom.right.equalToSuperview()
            $0.left.equalTo(timeLabel.snp.right).offset(20)
        }
        
        breakTimeView.addSubview(breakTimeLabel)
        breakTimeView.addSubview(breakTimeTextField)
        
        breakTimeLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.left.equalToSuperview().inset(16)
        }
        
        breakTimeTextField.snp.makeConstraints {
            $0.top.bottom.right.equalToSuperview()
            $0.left.equalTo(breakTimeLabel.snp.right).offset(20)
        }
        
        timeView.isHidden = exerciseType == .strength
        setsView.isHidden = exerciseType == .cardio
    }
}
