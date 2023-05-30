//
//  WorkoutSummaryCollectionViewcell.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 31/05/2023.
//

import UIKit
import SnapKit

class WorkoutSummaryCollectionViewCell: UICollectionViewCell, CollectionViewReusableCell {
    typealias L = Localization.TrainingAssistantFlow
    
    struct ViewModel {
        let exerciseName: String
        let exerciseType: Exercise.ExerciseType
        let numberOfSets: Int?
        let maxRepetitions: Int?
        let totalTime: Int?
        let maxWeight: Float?
        let distance: Float?
    }
    
    // MARK: Properties
    
    private lazy var mainView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [exerciseNameLabel, setsNumberLabel, totalTimeLabel, distanceLabel, maxWeightLabel, maxRepetitionsLabel])
        view.axis = .vertical
        view.backgroundColor = .quaternaryColor
        view.layer.cornerRadius = 12
        view.spacing = 4
        return view
    }()
    
    private lazy var exerciseNameLabel: UILabel = {
        let label = UILabel()
        label.font = .openSansSemiBold20
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private lazy var setsNumberLabel: PaddingLabel = generateResultLabel()
    private lazy var totalTimeLabel: PaddingLabel = generateResultLabel()
    private lazy var distanceLabel: PaddingLabel = generateResultLabel()
    private lazy var maxWeightLabel: PaddingLabel = generateResultLabel()
    private lazy var maxRepetitionsLabel: PaddingLabel = generateResultLabel()
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(mainView)
        layoutViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Public Implementation
    
    func configure(with viewModel: ViewModel) {
        exerciseNameLabel.text = viewModel.exerciseName
        guard let sets = viewModel.numberOfSets else { return }
        setsNumberLabel.text = L.setsTitle + "\(sets)"
        switch viewModel.exerciseType {
        case .cardio:
            if let distance = viewModel.distance {
                distanceLabel.text = L.distanceTitle + "\(distance)"
            }
            if let time = viewModel.totalTime {
                totalTimeLabel.text = L.totalTimeTitle + "\(Int.calculateFormattedDuration(duration: time))"
            }
        case .strength:
            totalTimeLabel.text = ""
            if let maxWeight = viewModel.maxWeight {
                maxWeightLabel.text = L.maxWeightTitle + "\(maxWeight)"
            }
            if let maxRepetitions = viewModel.maxRepetitions {
                maxRepetitionsLabel.text = L.maxRepetitionsTitle + "\(maxRepetitions)"
            }
        }
    }
    
    // MARK: Private Implementation
    
    private func layoutViews() {
        backgroundColor = .clear
        mainView.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(4)
            $0.top.bottom.equalToSuperview().inset(12)
        }
    }
    
    private func generateResultLabel() -> PaddingLabel {
        let label = PaddingLabel(withInsets: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0))
        label.font = .openSansSemiBold14
        label.textColor = .white
        label.textAlignment = .left
        return label
    }
}
