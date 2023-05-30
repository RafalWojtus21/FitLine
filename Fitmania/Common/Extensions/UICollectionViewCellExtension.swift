//
//  UICollectionViewCellExtension.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 31/05/2023.
//

import UIKit

protocol CollectionViewReusableCell: UICollectionViewCell {
    static var reuseIdentifier: String { get }
}

extension CollectionViewReusableCell {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UICollectionView {
    func register(_ cell: CollectionViewReusableCell.Type) {
        register(cell.self, forCellWithReuseIdentifier: cell.reuseIdentifier)
    }
}
