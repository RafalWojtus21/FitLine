//
//  CircularProgressBarView.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 11/05/2023.
//

import UIKit
import SnapKit

class CircularProgressBarView: UIView {
    
    // MARK: Properties
    
    private lazy var mainView = UIView(backgroundColor: .clear)
    private let lineWidth: CGFloat = 20
    
    private lazy var progressLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.lineWidth = lineWidth
        layer.strokeStart = 0
        layer.strokeEnd = 0
        layer.strokeColor = UIColor.primaryColor.cgColor
        layer.fillColor = UIColor.clear.cgColor
        return layer
    }()
    
    private lazy var trackLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.lineWidth = lineWidth
        layer.strokeStart = 0
        layer.strokeEnd = 1
        layer.strokeColor = UIColor.primaryColor.withAlphaComponent(0.4).cgColor
        layer.fillColor = UIColor.clear.cgColor
        return layer
    }()

    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Private Implementation
    
    private func setupView() {
        addSubview(mainView)
    
        mainView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        mainView.layer.addSublayer(trackLayer)
        mainView.layer.addSublayer(progressLayer)
    }
    
    // MARK: Public Implementation

    func setProgress(duration: Float) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = CFTimeInterval(duration)
        progressLayer.beginTime = 0.0
        progressLayer.timeOffset = 0.0
        progressLayer.strokeEnd = CGFloat(duration)
        progressLayer.add(animation, forKey: AnimationKeys.circularProgressAnimation)
    }
    
    func pauseAnimation() {
        layer.pauseAnimation()
    }
    
    func resumeAnimation() {
        layer.resumeAnimation()
    }
    
    func removeAnimation() {
        progressLayer.removeAnimation(forKey: AnimationKeys.circularProgressAnimation)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let path = UIBezierPath(arcCenter: .init(x: mainView.frame.width / 2, y: mainView.frame.height / 2), radius: (mainView.frame.height / 2) - 20, startAngle: CGFloat(-0.5 * Double.pi), endAngle: CGFloat(1.5 * Double.pi), clockwise: true)
        progressLayer.path = path.cgPath
        trackLayer.path = path.cgPath
    }
}

extension CALayer {
    
    var isPaused: Bool {
        speed == 0
    }
    
    func pauseAnimation() {
        guard !isPaused else { return }
        let pausedTime = convertTime(CACurrentMediaTime(), from: nil)
        speed = 0.0
        timeOffset = pausedTime
    }

    func resumeAnimation() {
        guard isPaused else { return }
        let pausedTime = timeOffset
        speed = 1.0
        timeOffset = 0.0
        beginTime = 0.0
        let timeSincePause = convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        beginTime = timeSincePause
    }
}
