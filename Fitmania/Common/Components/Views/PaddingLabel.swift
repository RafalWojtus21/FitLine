//
//  PaddingLabel.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 31/05/2023.
//

import UIKit

class PaddingLabel: UILabel {

    var edgeInsets: UIEdgeInsets

    required init(withInsets edgeInsets: UIEdgeInsets) {
        self.edgeInsets = edgeInsets
        super.init(frame: CGRect.zero)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: edgeInsets))
    }

    override var intrinsicContentSize: CGSize {
        var contentSize = super.intrinsicContentSize
        contentSize.height += edgeInsets.top + edgeInsets.bottom
        contentSize.width += edgeInsets.left + edgeInsets.right
        return contentSize
    }
}
