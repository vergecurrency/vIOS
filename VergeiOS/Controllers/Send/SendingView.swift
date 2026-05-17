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

    // TODO: Add this to an abstract class.
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

        setupListeners()
        animateImage()

        return alertController
    }

    func showError(_ errorResponse: Vws.TxProposalErrorResponse) {
        statusLabel.text = errorResponse.message
    }

    private func setupListeners() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleNotification(notification:)),
                                               name: .didPublishTx,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleNotification(notification:)),
                                               name: .didSignTx,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleNotification(notification:)),
                                               name: .didBroadcastTx, object: nil)
    }

    private func animateImage() {
        var imgListArray: [UIImage] = []
        for countValue in 5...23 {
            let strImageName: String = "frame-\(countValue)"
            let image = UIImage(named: strImageName)

            imgListArray.append(image!)
        }

        imageView.animationImages = imgListArray
        imageView.animationDuration = 4.5
        imageView.startAnimating()
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
        statusLabel.textColor = .white
        imageView.tintColor = ThemeManager.shared.primaryLight()
    }

    @objc private func handleNotification(notification: Notification) {
        DispatchQueue.main.async {
            switch notification.name {
            case Notification.Name.didPublishTx:
                self.statusLabel.text = "send.sending.signingTransaction".localized
            case Notification.Name.didSignTx:
                self.statusLabel.text = "send.sending.broadcastingTransaction".localized
            case Notification.Name.didBroadcastTx:
                self.statusLabel.text = "send.sending.transactionSent".localized
            default:
                break
            }
        }

        NotificationCenter.default.removeObserver(self, name: notification.name, object: nil)
    }
}
