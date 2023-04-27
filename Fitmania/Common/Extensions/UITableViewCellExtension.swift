//
//  UITableViewCellExtension.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 04/05/2023.
//

import UIKit

protocol ReusableCell: UITableViewCell {
    static var reuseIdentifier: String { get }
}

extension ReusableCell {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UITableView {
    func register(_ cell: ReusableCell.Type) {
        register(cell.self, forCellReuseIdentifier: cell.reuseIdentifier)
    }
}
