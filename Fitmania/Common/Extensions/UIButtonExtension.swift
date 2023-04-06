//
//  ButtonsFactory.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 06/04/2023.
//

import UIKit

enum ButtonStyle {
    case primary
    case secondary
}

extension UIButton {
    func apply(style: ButtonStyle) -> UIButton {
        setTitleColor(.black, for: .normal)
        switch style {
        case .primary:
            backgroundColor = .primaryColor
            layer.cornerRadius = 25
        case .secondary:
            backgroundColor = .secondaryColor
            layer.cornerRadius = 2
        }
        return self
    }
}
