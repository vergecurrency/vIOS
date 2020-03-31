//
//  WalletNotificationView.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 30/03/2020.
//  Copyright © 2020 Verge Currency. All rights reserved.
//

import UIKit

class WalletNotificationView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!

    static var shared: WalletNotificationView?

    typealias ClickedCompletion = (() -> Void)
    var clickedCompletion: ClickedCompletion?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }

    private func commonInit() {
        Bundle.main.loadNibNamed("WalletNotificationView", owner: self)

        self.isHidden = true
        self.addSubview(contentView)
        self.contentView.frame = self.bounds
        self.contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]

        WalletNotificationView.shared = self
    }

    func warning(title: String, message: String, completion: @escaping ClickedCompletion) {
        self.show(title: title, message: message, completion: completion)

        if #available(iOS 13.0, *) {
            self.imageView.image = UIImage(systemName: "exclamationmark.triangle.fill")
            self.imageView.tintColor = .orange
            self.imageView.isHidden = false
        }
    }

    func show(title: String, message: String, completion: @escaping ClickedCompletion) {
        self.clickedCompletion = completion

        self.imageView.isHidden = true
        self.titleLabel.text = title
        self.messageLabel.text = message
        self.alpha = 0.0
        self.layoutIfNeeded()

        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 1.0
            self.isHidden = false
            self.layoutIfNeeded()
        })
    }

    func hide() {
        self.alpha = 1.0

        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0.0
            self.isHidden = true
            self.layoutIfNeeded()
        })
    }

    @IBAction func clicked(_ sender: UIButton) {
        if let clickedCompletion = self.clickedCompletion {
            clickedCompletion()
        }
    }
}
