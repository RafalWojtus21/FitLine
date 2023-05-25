//
//  UIViewExtension.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 17/04/2023.
//

import UIKit

extension UIView {
    
    convenience init(backgroundColor: UIColor) {
        self.init()
        self.backgroundColor = backgroundColor
    }
    
    func fadeIn(withDuration duration: Double = 0.5) {
        guard alpha == 0 else { return }
        UIView.animate(withDuration: TimeInterval(duration)) {
            self.alpha = 1
        }
    }
    
    func fadeOut(withDuration duration: Double = 0.5, completion: (() -> Void)? = nil) {
        guard alpha == 1 else { return }
        UIView.animate(withDuration: TimeInterval(duration)) {
            self.alpha = 0
        } completion: { isFinished in
            if isFinished {
                completion?()
            }
        }
    }
}
