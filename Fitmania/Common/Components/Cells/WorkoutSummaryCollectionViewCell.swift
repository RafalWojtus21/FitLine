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
        let weightRepetitionsModel: [WorkoutSummaryModel.WeightRepetitionsModel]
        var maxRepetitions: Int? { weightRepetitionsModel.compactMap { $0.repetitions }.max() }
        let totalTime: Int?
        var maxWeight: Float? { weightRepetitionsModel.compactMap { $0.weight }.max() }
        let distance: Float?
    }
    
    // MARK: Properties
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isScrollEnabled = true
        scrollView.indicatorStyle = .white
        scrollView.backgroundColor = .quaternaryColor
        scrollView.layer.cornerRadius = 12
        return scrollView
    }()
    
    private lazy var mainView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [exerciseNameLabel, setsNumberLabel, totalTimeLabel, distanceLabel, maxWeightLabel, maxRepetitionsLabel])
        view.axis = .vertical
        view.spacing = 4
        return view
    }()
    
    private lazy var exerciseNameLabel: UILabel = {
        let label = UILabel()
        label.font = .openSansSemiBold20
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
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
        contentView.addSubview(scrollView)
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
        scrollView.snp.remakeConstraints {
            $0.left.right.equalToSuperview().inset(4)
            $0.top.bottom.equalToSuperview().inset(12)
        }
        
        scrollView.addSubview(mainView)
        mainView.snp.remakeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
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
