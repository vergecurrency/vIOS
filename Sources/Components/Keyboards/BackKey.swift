//
//  BackKey.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 24-07-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class BackKey: ImageKey {
    init() {
        let image = UIImage(systemName: "delete.left")
            ?? UIImage(named: "Backspace")!
        super.init(image: image)
    }

    override func styleKey(_ button: KeyboardButton) {
        super.styleKey(button)
        button.setImage(nil, for: .normal)
        button.setTitle(nil, for: .normal)

        let labelTag = 778_412
        button.subviews
            .filter { $0.tag == labelTag }
            .forEach { $0.removeFromSuperview() }

        let label = UILabel()
        label.tag = labelTag
        label.text = "⌫"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 28, weight: .semibold)
        label.textAlignment = .center
        label.isUserInteractionEnabled = false
        label.translatesAutoresizingMaskIntoConstraints = false

        button.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: button.centerYAnchor, constant: -1),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: button.leadingAnchor, constant: 6),
            label.trailingAnchor.constraint(lessThanOrEqualTo: button.trailingAnchor, constant: -6)
        ])
        button.bringSubviewToFront(label)
    }
}
