//
//  TableHeaderView.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 25/07/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import UIKit

class TableHeaderView: UIView {
    private let title: String!
    private let image: UIImage!

    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = self.title
        titleLabel.textColor = ThemeManager.shared.secondaryDark()
        titleLabel.font = UIFont.avenir(size: 22).demiBold()
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0

        return titleLabel
    }()

    lazy var imageView: UIImageView = {
        let imageView = UIImageView(image: self.image)
        imageView.contentMode = .scaleAspectFit

        return imageView
    }()

    override init(frame: CGRect) {
        self.title = ""
        self.image = UIImage()
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        self.title = ""
        self.image = UIImage()
        super.init(coder: aDecoder)
    }

    init?(title: String, image: UIImage) {
        self.title = title
        self.image = image

        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 200))

        self.setupView()
    }

    private func setupView() {
        self.addSubview(self.titleLabel)
        self.addSubview(self.imageView)
        self.setupLayout()
    }

    private func setupLayout() {
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
        self.titleLabel.bottomAnchor.constraint(equalTo: self.imageView.topAnchor, constant: -8).isActive = true
        self.titleLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 300).isActive = true
        self.titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0).isActive = true

        let titleLeadingContraint = self.titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 40)
        titleLeadingContraint.isActive = true
        titleLeadingContraint.priority = .defaultHigh

        let titleTrailingContraint = self.titleLabel.trailingAnchor.constraint(
            equalTo: self.trailingAnchor,
            constant: -40
        )
        titleTrailingContraint.isActive = true
        titleTrailingContraint.priority = .defaultHigh

        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 8).isActive = true
        self.imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 40).isActive = true
        self.imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -40).isActive = true
        self.imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 8).isActive = true
        self.imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0).isActive = true
    }

    // custom views should override this to return true if
    // they cannot layout correctly using autoresizing.
    // from apple docs https://developer.apple.com/documentation/uikit/uiview/1622549-requiresconstraintbasedlayout
    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
}
