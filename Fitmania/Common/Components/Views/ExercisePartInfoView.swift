//
//  ExercisePartInfoView.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 11/05/2023.
//

import UIKit
import SnapKit

class ExercisePartInfoView: UIView {
    
    // MARK: Properties
    
    struct ViewModel {
        let eventName: String
        let eventDuration: Int
    }
    
    private lazy var mainView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [eventNameLabel, eventDurationLabel])
        view.axis = .vertical
        view.spacing = 2
        view.backgroundColor = .primaryColor
        view.distribution = .fillProportionally
        view.layer.cornerRadius = 12
        return view
    }()

    private lazy var eventNameLabel: UILabel = {
        let label = UILabel()
        label.font = .openSansSemiBold20
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private lazy var eventDurationLabel: UILabel = {
        let label = UILabel()
        label.font = .openSansSemiBold16
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Public Implementation

    func configure(with viewModel: ViewModel) {
        eventNameLabel.text = viewModel.eventName
        eventDurationLabel.text = "\(viewModel.eventDuration)" + " sec"
    }
    
    // MARK: Private Implementation
    
    private func layoutViews() {
        backgroundColor = .clear
        
        addSubview(mainView)
        mainView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
