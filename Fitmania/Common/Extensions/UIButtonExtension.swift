//
//  ButtonsFactory.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 06/04/2023.
//

import UIKit
import RxCocoa

enum ButtonStyle {
    case primary
    case secondary
    case tertiary
    case quaternary
}

enum BarButtonStyle {
    case rightButtonItem
    case leftButtonItem
    case rightStringButtonItem
}

extension UIButton {
    func apply(style: ButtonStyle, title: String) -> UIButton {
        setTitle(title, for: .normal)
        setTitleColor(.black, for: .normal)
        titleLabel?.font = .openSansRegular14
        switch style {
        case .primary:
            backgroundColor = isEnabled ? .tertiaryColor : .tertiaryColorDisabled
            layer.cornerRadius = 25
        case .secondary:
            backgroundColor = .secondaryColor
            layer.cornerRadius = 2
        case .tertiary:
            backgroundColor = .clear
            setTitleColor(.quinaryColor, for: .normal)
            titleLabel?.font = .openSansSemiBold14
        case .quaternary:
            layer.cornerRadius = 25
            backgroundColor = .white
        }
        return self
    }
}

extension UIBarButtonItem {
    func apply(style: BarButtonStyle, imageName: SystemImage?, title: String?) -> UIBarButtonItem? {
        let button = UIButton()
        button.backgroundColor = .clear
        switch style {
        case .rightButtonItem:
            guard let imageName else { return nil }
            button.semanticContentAttribute = .forceRightToLeft
            button.setImage(UIImage.systemImageName(imageName), for: .normal)
        case .leftButtonItem:
            guard let imageName else { return nil }
            button.semanticContentAttribute = .forceLeftToRight
            button.setImage(UIImage.systemImageName(imageName), for: .normal)
        case .rightStringButtonItem:
            button.setTitle(title, for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.semanticContentAttribute = .forceRightToLeft
        }
        return UIBarButtonItem(customView: button)
    }
    
    var tap: ControlEvent<Void> {
        guard let button = customView as? UIButton else {
            fatalError("Invalid custom view")
        }
        return button.rx.tap
    }
}

extension NSAttributedString {
    static func createAttributedString(text: String?, color: UIColor?, font: UIFont?) -> NSAttributedString {
        guard let text else { return .init() }
        let stringAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.foregroundColor: color ?? UIColor.black,
                                                               NSAttributedString.Key.font: font as Any]
        let attributedString = NSAttributedString(string: text, attributes: stringAttributes)
        return attributedString
    }
}
