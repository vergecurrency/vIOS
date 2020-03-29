//
// Created by Swen van Zanten on 14/10/2018.
// Copyright (c) 2018 Verge Currency. All rights reserved.
//

import UIKit

class NotificationManager: UIWindow {

    static var shared = NotificationManager()
    var notificationViewController: NotificationViewController?

    func initialize() {
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 0)
        self.notificationViewController = NotificationViewController(
            nibName: "NotificationViewController",
            bundle: .main
        )

        self.notificationViewController?.view.frame = frame
        self.frame = frame
        self.windowLevel = UIWindow.Level.statusBar + 1
    }

    func frameHeight() -> CGFloat {
        self.hasNotch() ? 66 : 36
    }

    func hasNotch() -> Bool {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return false
        }

        if #available(iOS 12.0, *) {
            if self.safeAreaInsets != UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0) {
                return true
            }
        }

        return false
    }

    func showMessage(_ message: String, duration: Double = 0) {
        self.rootViewController = self.notificationViewController

        self.notificationViewController?.setMessage(message)
        self.notificationViewController?.view.addTapGestureRecognizer(action: {
            self.removeMessage()
        })

        self.makeKeyAndVisible()
        self.layoutIfNeeded()
        self.toggleView(show: true)

        if duration > 0 {
            Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { _ in
                self.removeMessage()
            }
        }
    }

    func removeMessage() {
        self.toggleView(show: false)
    }

    private func toggleView(show: Bool) {
        UIView.animate(withDuration: 0.3, animations: {
            self.frame = CGRect(
                x: 0,
                y: 0,
                width: UIScreen.main.bounds.size.width,
                height: show ? self.frameHeight() : 0
            )
            self.layoutIfNeeded()
        }, completion: { _ in
            if !show {
                self.resignKey()
            }
        })
    }

    override func resignKey() {
        super.resignKey()

        self.rootViewController = nil
    }
}
