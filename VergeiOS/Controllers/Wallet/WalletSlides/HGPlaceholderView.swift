//
//  Untitled.swift
//  VergeiOS
//
//  Created by shami kapoor on 26/09/25.
//  Copyright © 2025 Verge Currency. All rights reserved.
//

import UIKit

public class HGPlaceholderView: UIView {

    private let label = UILabel()
    private let imageView = UIImageView()

    public init(text: String = "No Data", image: UIImage? = nil) {
        super.init(frame: .zero)
        setup(text: text, image: image)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup(text: "No Data", image: nil)
    }

    private func setup(text: String, image: UIImage?) {
        backgroundColor = UIColor.systemGray6
        layer.cornerRadius = 8
        clipsToBounds = true

        if let img = image {
            imageView.image = img
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(imageView)
        }

        label.text = text
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16)
        ])

        if imageView.superview != nil {
            NSLayoutConstraint.activate([
                imageView.bottomAnchor.constraint(equalTo: label.topAnchor, constant: -12),
                imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
                imageView.widthAnchor.constraint(lessThanOrEqualToConstant: 100),
                imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor)
            ])
        }
    }
}
