//
// Created by Swen van Zanten on 05/04/2020.
// Copyright (c) 2020 Verge Currency. All rights reserved.
//

import UIKit
import SwiftUI

class TorFixer: UIWindow {
    static var shared = TorFixer()

    var presented: Bool = false
    var torFixViewController: TorFixViewController = {
        return TorFixViewController(nibName: "TorFixViewController", bundle: .main)
    }()

    func present() {
        if self.presented {
            return
        }

        self.frame = UIScreen.main.bounds
        self.windowLevel = UIWindow.Level.torFixer
        self.rootViewController = self.torFixViewController
        self.alpha = 0.0

        self.presented = true
        self.makeKeyAndVisible()

        UIView.transition(with: self, duration: 0.5, options: .transitionFlipFromRight, animations: {
            self.alpha = 1.0
        })
    }
}
