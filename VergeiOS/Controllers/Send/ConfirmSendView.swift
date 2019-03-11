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
        let amount = NSNumber(floatLiteral: Double(txp.amount) / Constants.satoshiDivider)
        let fee = NSNumber(floatLiteral: Double(txp.fee) / Constants.satoshiDivider)
        let total = NSNumber(floatLiteral: amount.doubleValue + fee.doubleValue)

        let output = txp.outputs.first!
        
        sendingAmountLabel.text = amount.toXvgCurrency()
        transactionFeeAmountLabel.text = fee.toXvgCurrency()
        totalXvgAmountLabel.text = total.toXvgCurrency()
        recipientAddressLabel.text = (output.stealth ?? false)
            ? "Resolved stealth address 🕵️‍♀️"
            : output.toAddress

        if let xvgInfo = FiatRateTicker.shared.rateInfo {
            let totalFiat = total.doubleValue * xvgInfo.price

            totalFiatAmountLabel.text = NSNumber(floatLiteral: totalFiat).toPairCurrency()
        }

        activityIndicatorView.removeFromSuperview()
    }
    
}
