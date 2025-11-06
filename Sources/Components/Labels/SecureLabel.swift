//
//  SecureLabel.swift
//  VergeiOS
//
//  Created by Ivan Manov on 28.07.2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import UIKit

class SecureLabel: UILabel {

    let appRepo =  Application.container.resolve(ApplicationRepository.self)!

    @IBInspectable var tapToToggle: Bool = false

    // MARK: Overrided methods

    override func didMoveToWindow() {
        super.didMoveToWindow()

        if tapToToggle == true {
            self.addTapGestureRecognizer {
                self.toggleSecure()
            }
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didChangeSecureContent(notification:)),
            name: .didChangeSecureContent,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didDeviceShaken(notification:)),
            name: .didDeviceShaken,
            object: nil
        )
    }

    // MARK: Overrided properties

    override public var text: String? {
        get {
            return self.secureText
        }
        set {
            self.originText = newValue
            super.text = self.secureText
            self.setNeedsDisplay()
        }
    }

    // MARK: Properties

    var originText: String?
    var secureText: String? {
        if self.originText != nil {
            return self.secure ? "•••••" : self.originText
        }
        return originText
    }

    // MARK: Public properties

    var secure: Bool {
        get {
            return appRepo.secureContent
        }
        set {
            appRepo.secureContent = newValue
        }
    }

    // MARK: Public methods

    func toggleSecure() {
        self.secure = !self.secure
        self.update()
    }

    // MARK: Notifications

    @objc private func didChangeSecureContent(notification: Notification? = nil) {
        self.update()
    }

    @objc private func didDeviceShaken(notification: Notification? = nil) {
        self.shake()
    }

    // MARK: Private methods

    private func update() {
        self.text = self.originText
    }

}
