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
        return 320.0
    }

    func makeActionSheet() -> UIAlertController {
        let viewHeight: CGFloat = subviews.first?.frame.height ?? 0
        let lineHeight: CGFloat = 18.33
        let times = (viewHeight / lineHeight).rounded()
        let enters: String = String(repeating: "\n", count: Int(times))

        let alertController = UIAlertController(title: enters, message: nil, preferredStyle: .actionSheet)

        let width = UIDevice.current.userInterfaceIdiom == .pad ? iPadWidth : alertController.view.bounds.size.width

        frame = CGRect(
            x: 0,
            y: 0,
            width: width - margin * 2.0,
            height: viewHeight
        )

        let container = UIView(frame: frame)
        container.addSubview(self)

        alertController.view.addSubview(container)

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

}
