//
//  ConfirmSendView.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 24-08-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class ConfirmSendView: UIView {

    @IBOutlet weak var sendingAmountLabel: UILabel!
    @IBOutlet weak var transactionFeeAmountLabel: UILabel!
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

    func setup(_ txp: TxProposalResponse) {
        let amount = NSNumber(value: Double(txp.amount) / Constants.satoshiDivider)
        let fee = NSNumber(value: Double(txp.fee) / Constants.satoshiDivider)
        let total = NSNumber(value: amount.doubleValue + fee.doubleValue)

        let output = txp.outputs.first!

        self.sendingAmountLabel.text = amount.toXvgCurrency()
        self.transactionFeeAmountLabel.text = fee.toXvgCurrency()
        self.totalXvgAmountLabel.text = total.toXvgCurrency()
        self.recipientAddressLabel.text = (output.stealth ?? false)
            ? "send.confirm.resolvedStealth".localized + " 🕵️‍♀️"
            : output.toAddress

        let applicationRepository = Application.container.resolve(ApplicationRepository.self)

        if let xvgInfo = applicationRepository?.latestRateInfo {
            let totalFiat = total.doubleValue * xvgInfo.price

            self.totalFiatAmountLabel.text = NSNumber(value: totalFiat).toPairCurrency()
        }

        self.activityIndicatorView.removeFromSuperview()
    }

}
