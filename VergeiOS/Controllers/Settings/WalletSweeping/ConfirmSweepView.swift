//
//  ConfirmSweepView.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 06/08/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import UIKit

class ConfirmSweepView: UIView {

    @IBOutlet weak var totalXvgAmountLabel: UILabel!
    @IBOutlet weak var totalFiatAmountLabel: UILabel!
    @IBOutlet weak var recipientAddressLabel: UILabel!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!

    var margin: CGFloat {
        if #available(iOS 12.0, *) {
            return 8.0
        } else {
            return 10.0
        }
    }

    var iPadWidth: CGFloat {
        return 380.0
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        applyRetrowaveStyle()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        applyRetrowaveStyle()
    }

    func makeActionSheet() -> UIAlertController {
        let viewHeight: CGFloat = subviews.first?.frame.height ?? 0
        let lineHeight: CGFloat = 18.33
        let times = (viewHeight / lineHeight).rounded()
        let enters: String = String(repeating: "\n", count: Int(times))

        let alertController = UIAlertController(title: enters, message: nil, preferredStyle: .actionSheet)
        let contentWidth = UIDevice.current.userInterfaceIdiom == .pad
            ? iPadWidth
            : min(UIScreen.main.bounds.width - 32.0, 360.0)

        frame = CGRect(x: 0, y: 0, width: contentWidth, height: viewHeight)

        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .clear
        container.clipsToBounds = false
        container.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false

        alertController.view.addSubview(container)
        NSLayoutConstraint.activate([
            container.centerXAnchor.constraint(equalTo: alertController.view.centerXAnchor),
            container.topAnchor.constraint(equalTo: alertController.view.topAnchor, constant: margin),
            container.widthAnchor.constraint(equalToConstant: contentWidth),
            container.heightAnchor.constraint(equalToConstant: viewHeight),

            leadingAnchor.constraint(equalTo: container.leadingAnchor),
            trailingAnchor.constraint(equalTo: container.trailingAnchor),
            topAnchor.constraint(equalTo: container.topAnchor),
            bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        return alertController
    }

    func setup(toAddress address: String, amount: NSNumber) {
        self.totalXvgAmountLabel.text = amount.toXvgCurrency()
        self.recipientAddressLabel.text = address

        let applicationRepository = Application.container.resolve(ApplicationRepository.self)

        if let xvgInfo = applicationRepository?.latestRateInfo {
            let totalFiat = amount.doubleValue * xvgInfo.price

            self.totalFiatAmountLabel.text = NSNumber(value: totalFiat).toPairCurrency()
        }

        self.activityIndicatorView.removeFromSuperview()
    }

    private func applyRetrowaveStyle() {
        backgroundColor = .clear
        guard let card = subviews.first else {
            return
        }

        card.backgroundColor = ThemeManager.shared.backgroundWhite()
        card.layer.cornerRadius = 16
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor(rgb: 0xFF3DF2).withAlphaComponent(0.55).cgColor
        card.layer.shadowColor = UIColor(rgb: 0xFF3DF2).cgColor
        card.layer.shadowOpacity = 0.28
        card.layer.shadowRadius = 18
        card.layer.shadowOffset = CGSize(width: 0, height: 0)
        card.clipsToBounds = false
        styleSubviews(in: card)
    }

    private func styleSubviews(in root: UIView) {
        root.subviews.forEach { styleSubviews(in: $0) }

        if let label = root as? UILabel {
            label.textColor = label.font.pointSize >= 16
                ? .white
                : ThemeManager.shared.secondaryLight()
        }
    }

}
