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
    case tertiary
}

extension UIButton {
    func apply(style: ButtonStyle, title: String) -> UIButton {
        setTitle(title, for: .normal)
        setTitleColor(.black, for: .normal)
        titleLabel?.font = .openSansRegular14
        switch style {
        case .primary:
            backgroundColor = isEnabled ? .primaryColor : .primaryDisabledColor
            layer.cornerRadius = 25
        case .secondary:
            backgroundColor = .secondaryColor
            layer.cornerRadius = 2
        case .tertiary:
            backgroundColor = .clear
            setTitleColor(.quinaryColor, for: .normal)
            titleLabel?.font = .openSansSemiBold14
        }
        return self
    }
}
