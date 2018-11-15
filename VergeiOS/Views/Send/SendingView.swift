//
//  SendingView.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 15/11/2018.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class SendingView: UIView {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!

    var margin: CGFloat {
        if #available(iOS 12.0, *) {
            return 8.0
        } else {
            return 10.0
        }
    }

    // TODO: Add this to an abstract class.
    func makeActionSheet() -> UIAlertController {
        let viewHeight: CGFloat = subviews.first?.frame.height ?? 0
        let lineHeight: CGFloat = 18.33
        let times = (viewHeight / lineHeight).rounded()
        let enters: String = String(repeating: "\n", count: Int(times))

        let alertController = UIAlertController(title: enters, message: nil, preferredStyle: .actionSheet)

        frame = CGRect(
            x: 0,
            y: 0,
            width: alertController.view.bounds.size.width - margin * 2.0,
            height: viewHeight
        )

        let container = UIView(frame: frame)
        container.addSubview(self)

        alertController.view.addSubview(container)

        setupListeners()
        animateImage()

        return alertController
    }

    private func setupListeners() {
        NotificationCenter.default.addObserver(self, selector: #selector(didCreateTx(notification:)), name: .didCreateTx, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didPublishTx(notification:)), name: .didPublishTx, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didSignTx(notification:)), name: .didSignTx, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didBroadcastTx(notification:)), name: .didBroadcastTx, object: nil)
    }

    private func animateImage() {
        var imgListArray: [UIImage] = []
        for countValue in 0...31 {
            let strImageName: String = "frame-\(countValue)"
            let image = UIImage(named: strImageName)

            imgListArray.append(image!)
        }

        imageView.animationImages = imgListArray;
        imageView.animationDuration = 5.5
        imageView.startAnimating()
    }

    @objc private func didCreateTx(notification: Notification) {
        DispatchQueue.main.async {
            self.statusLabel.text = "Publishing Transaction"
        }

        NotificationCenter.default.removeObserver(self, name: .didCreateTx, object: nil)
    }

    @objc private func didPublishTx(notification: Notification) {
        DispatchQueue.main.async {
            self.statusLabel.text = "Signing Transaction"
        }

        NotificationCenter.default.removeObserver(self, name: .didPublishTx, object: nil)
    }

    @objc private func didSignTx(notification: Notification) {
        DispatchQueue.main.async {
            self.statusLabel.text = "Broadcasting Transaction"
        }

        NotificationCenter.default.removeObserver(self, name: .didSignTx, object: nil)
    }

    @objc private func didBroadcastTx(notification: Notification) {
        DispatchQueue.main.async {
            self.statusLabel.text = "Transaction Sent!"
        }

        NotificationCenter.default.removeObserver(self, name: .didBroadcastTx, object: nil)
    }
}
