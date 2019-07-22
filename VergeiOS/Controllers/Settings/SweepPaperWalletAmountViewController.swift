//
//  SweepPaperWalletAmountViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 19/07/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import UIKit

class SweepPaperWalletAmountViewController: UIViewController {

    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Yeah! Found a private key!"
        label.font = UIFont.avenir(size: 22).demiBold()
        label.textColor = ThemeManager.shared.secondaryDark()
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true

        return label
    }()

    override func loadView() {
        super.loadView()

        self.view = UIView()
        self.view.backgroundColor = ThemeManager.shared.backgroundGrey()

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .stop,
            target: self,
            action: #selector(closeView(sender:))
        )
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(self.titleLabel)

        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.topAnchor.constraint(
            equalTo: self.view.layoutMarginsGuide.topAnchor,
            constant: 8
        ).isActive = true
        self.titleLabel.leadingAnchor.constraint(
            equalTo: self.view.layoutMarginsGuide.leadingAnchor,
            constant: 40
        ).isActive = true
        self.titleLabel.trailingAnchor.constraint(
            equalTo: self.view.layoutMarginsGuide.trailingAnchor,
            constant: -40
        ).isActive = true
        self.titleLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }

    @objc
    private func closeView(sender: Any) {
        self.dismiss(animated: true)
    }
}
