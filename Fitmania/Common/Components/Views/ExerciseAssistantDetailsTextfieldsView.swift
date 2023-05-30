//
//  ExerciseAssistantDetailsTextfieldsView.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 30/05/2023.
//

import UIKit

class ExerciseAssistantDetailsTextfieldsView: UIView {
    
    struct ViewModel {
        let detailsTypes: [Exercise.DetailsType]
    }
    
    // MARK: Properties
    
    private lazy var mainView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.backgroundColor = .clear
        return view
    }()
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Public Implementation
    
    func configure(with viewModel: ViewModel) {
        mainView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let detailsTypes = viewModel.detailsTypes
        let numberOfRows = (detailsTypes.count + 1) / 2
        for rowIndex in 0 ..< numberOfRows {
            let rowStackView = UIStackView()
            rowStackView.axis = .horizontal
            rowStackView.alignment = .center
            rowStackView.spacing = 12
            rowStackView.distribution = .fillEqually
            
            let startIndex = rowIndex * 2
            let endIndex = min(startIndex + 2, detailsTypes.count)
            for index in startIndex ..< endIndex {
                let textField = configureTextfield(detailsTypes: detailsTypes, currentIndex: index)
                rowStackView.addArrangedSubview(textField)
                textField.snp.makeConstraints {
                    $0.height.equalToSuperview()
                }
            }
            mainView.addArrangedSubview(rowStackView)
        }
    }
    
    func configureTextfield(detailsTypes: [Exercise.DetailsType], currentIndex: Int) -> UITextField {
        let textField = UITextField()
        switch detailsTypes[currentIndex] {
        case .repetitions:
            textField.keyboardType = .numberPad
        default:
            textField.keyboardType = .decimalPad
        }
        textField.backgroundColor = .primaryColor
        textField.attributedPlaceholder = NSAttributedString(string: detailsTypes[currentIndex].rawValue,
                                                   attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        textField.layer.cornerRadius = 8
        textField.textColor = .white
        textField.font = .openSansSemiBold20
        textField.setLeftPaddingPoints(12)
        return textField
    }
    
    func getTextfieldValues() -> [String] {
        var values: [String] = []
        for rowSubview in mainView.arrangedSubviews {
            guard let rowStackView = rowSubview as? UIStackView else { continue }
            for case let textField as UITextField in rowStackView.arrangedSubviews {
                if let text = textField.text {
                    values.append(text)
                }
            }
        }
        return values
    }
    
    // MARK: Private Implementation
    
    private func layoutViews() {
        addSubview(mainView)
        mainView.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(12)
            $0.bottom.top.equalToSuperview()
        }
    }
}
