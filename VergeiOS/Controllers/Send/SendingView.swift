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

    var iPadWidth: CGFloat {
        return 320.0
    }

    // TODO: Add this to an abstract class.
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

        setupListeners()
        animateImage()

        return alertController
    }

    func showError(_ errorResponse: TxProposalErrorResponse) {
        statusLabel.text = errorResponse.message
    }

    private func setupListeners() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(notification:)), name: .didPublishTx, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(notification:)), name: .didSignTx, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(notification:)), name: .didBroadcastTx, object: nil)
    }

    private func animateImage() {
        var imgListArray: [UIImage] = []
        for countValue in 5...23 {
            let strImageName: String = "frame-\(countValue)"
            let image = UIImage(named: strImageName)

            imgListArray.append(image!)
        }

        imageView.animationImages = imgListArray;
        imageView.animationDuration = 4.5
        imageView.startAnimating()
    }

    @objc private func handleNotification(notification: Notification) {
        DispatchQueue.main.async {
            switch notification.name {
            case Notification.Name.didPublishTx:
                self.statusLabel.text = "Signing Transaction"
                break
            case Notification.Name.didSignTx:
                self.statusLabel.text = "Broadcasting Transaction"
                break
            case Notification.Name.didBroadcastTx:
                self.statusLabel.text = "Transaction Sent!"
                break
            default:
                break
            }
        }

        NotificationCenter.default.removeObserver(self, name: notification.name, object: nil)
    }
}
