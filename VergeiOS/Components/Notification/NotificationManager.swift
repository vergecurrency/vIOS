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
        self.notificationViewController = NotificationViewController(nibName: "NotificationViewController", bundle: .main)
        self.notificationViewController?.view.frame = frame
        
        self.windowLevel = UIWindow.Level.statusBar + 1
        self.rootViewController = self.notificationViewController
        
        self.frame = frame
        
        self.layoutIfNeeded()
        self.makeKeyAndVisible()
    }
    
    func frameHeight() -> CGFloat {
        return hasNotch() ? 66 : 36
    }
    
    func hasNotch() -> Bool {
        var hasNotch = false
        if #available(iOS 12.0, *) {
            if self.safeAreaInsets != UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0) {
                hasNotch = true
            }
        }
        else if #available(iOS 11.0, *) {
            if self.safeAreaInsets != UIEdgeInsets.zero {
                hasNotch = true
            }
        }
        return hasNotch
    }
    
    func showMessage(_ message: String, duration: Double = 0) {
        notificationViewController?.setMessage(message)
        notificationViewController?.view.addTapGestureRecognizer(action: {
            self.removeMessage()
        })

        toggleView(show: true)

        if duration > 0 {
            Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { timer in
                self.removeMessage()
            }
        }
    }

    func removeMessage() {
        toggleView(show: false)
    }

    func toggleView(show: Bool) {
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: show ? self.frameHeight() : 0)
            self.frame = frame
            self.layoutIfNeeded()
        })
    }
}
