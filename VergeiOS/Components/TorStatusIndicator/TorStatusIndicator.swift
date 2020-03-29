//
//  TorStatusIndicator.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 11-09-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit
import SystemConfiguration

class TorStatusIndicator: UIWindow {

    enum Status {
        case connected
        case disconnected
        case turnedOff
        case error
    }

    static var shared = TorStatusIndicator()
    var torStatusIndicatorViewController: TorStatusIndicatorViewController?
    let defaultStatus: TorStatusIndicator.Status = .turnedOff
    var isShown = true

    func initialize() {
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: self.frameHeight())
        self.torStatusIndicatorViewController = TorStatusIndicatorViewController(
            nibName: "TorStatusIndicatorViewController",
            bundle: .main
        )
        self.torStatusIndicatorViewController?.view.frame = frame
        self.backgroundColor = .clear

        self.windowLevel = UIWindow.Level.statusBar - 2
        self.rootViewController = self.torStatusIndicatorViewController

        self.frame = frame

        self.layoutIfNeeded()

        self.torStatusIndicatorViewController?.setHasNotch(self.hasNotch())
        self.makeKeyAndVisible()
        self.isUserInteractionEnabled = false

        self.setStatus(self.defaultStatus)
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

    func frameHeight() -> CGFloat {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return UIScreen.main.bounds.size.height - 1
        }

        return self.hasNotch() ? 54 : 33
    }

    func setStatus(_ status: TorStatusIndicator.Status) {
        self.torStatusIndicatorViewController?.setStatus(status)
    }

    func refresh() {
        self.torStatusIndicatorViewController?.setStatus(self.torStatusIndicatorViewController!.status)
    }

    func hide() {
        self.toggleView(show: false)
    }

    func show() {
        self.toggleView(show: true)
    }

    func toggleView(show: Bool) {
        if self.isShown == show {
            return
        }

        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.center.y = show ? self.frameHeight() / 2 : -40
            self.alpha = show ? 1 : 0
            self.isShown = show
            self.layoutIfNeeded()
        })
    }
}
