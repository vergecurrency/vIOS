//
// Created by Swen van Zanten on 14/10/2018.
// Copyright (c) 2018 Verge Currency. All rights reserved.
//

import UIKit

class ThemeManager {

    static let shared = ThemeManager()

    var useMoonMode = false

    func initialize(withWindow window: UIWindow) {
        UITabBar.appearance().layer.borderWidth = 0
        UITabBar.appearance().layer.borderColor = UIColor.clear.cgColor
        UITabBar.appearance().clipsToBounds = true

        UITabBar.appearance().tintColor = self.primaryLight()
        UITabBar.appearance().barTintColor = self.backgroundGrey()
        UITabBar.appearance().backgroundColor = self.backgroundGrey()
        UITabBar.appearance().barStyle = self.useMoonMode ? .black : .default
        UITabBar.appearance().isTranslucent = !self.useMoonMode

        UIToolbar.appearance().tintColor = self.primaryLight()
        UIToolbar.appearance().barTintColor = self.backgroundWhite()
        UIToolbar.appearance().backgroundColor = self.backgroundWhite()
        UIToolbar.appearance().barStyle = self.useMoonMode ? .black : .default
        UIToolbar.appearance().isTranslucent = !self.useMoonMode

        UITableView.appearance().backgroundColor = self.backgroundGrey()
        UITableView.appearance().tintColor = self.primaryLight()
        UITableView.appearance().separatorColor = self.useMoonMode ? self.vergeGrey() : UIColor(rgb: 0xC8C7CC)

        let colorView = UIView()
        colorView.backgroundColor = self.backgroundBlue()

        UITableViewCell.appearance().selectedBackgroundView = colorView
        UITableViewCell.appearance().backgroundColor = self.backgroundWhite()

        UITextField.appearance().textColor = self.secondaryDark()
        UITextField.appearance().keyboardAppearance = self.useMoonMode ? .dark : .default
        UISearchBar.appearance().keyboardAppearance = self.useMoonMode ? .dark : .default

        window.tintColor = self.primaryLight()
    }

    func chooseColor(lightColor: UIColor, darkColor: UIColor) -> UIColor {
        return self.useMoonMode ? darkColor : lightColor
    }

    func separatorColor() -> UIColor {
        return self.useMoonMode ?
            self.vergeGrey() :
            UIColor(red: 0.85, green: 0.85, blue: 0.9, alpha: 1)
    }

    func primaryDark() -> UIColor {
        return self.chooseColor(lightColor: UIColor(rgb: 0x112034), darkColor: UIColor(rgb: 0xDCEFFC))
    }

    func primaryLight() -> UIColor {
        return self.chooseColor(lightColor: UIColor(rgb: 0x37BCE1), darkColor: UIColor(rgb: 0x37BCE1))
    }

    func secondaryDark() -> UIColor {
        return self.chooseColor(lightColor: UIColor(rgb: 0x183C54), darkColor: UIColor(rgb: 0xF8F7F7))
    }

    func secondaryLight() -> UIColor {
        return self.chooseColor(lightColor: UIColor(rgb: 0x637885), darkColor: UIColor(rgb: 0x738FA0))
    }

    func backgroundBlue() -> UIColor {
        return self.chooseColor(lightColor: UIColor(rgb: 0xDCEFFC), darkColor: UIColor(rgb: 0x113354))
    }

    func backgroundGrey() -> UIColor {
        return self.chooseColor(lightColor: UIColor(rgb: 0xF8F7F7), darkColor: UIColor(rgb: 0x101e2e))
    }

    func backgroundWhite() -> UIColor {
        return self.chooseColor(lightColor: UIColor(rgb: 0xFFFFFF), darkColor: UIColor(rgb: 0x19293c))
    }

    func vergeGrey() -> UIColor {
        return self.chooseColor(lightColor: UIColor(rgb: 0x9B9B9B), darkColor: UIColor(rgb: 0x3F5266))
    }

    func vergeGreen() -> UIColor {
        return UIColor(rgb: 0x008570)
    }

    func vergeRed() -> UIColor {
        return UIColor(rgb: 0xFF5252)
    }

    func placeholderColor() -> UIColor {
        return self.chooseColor(lightColor: UIColor(rgb: 0x000000).withAlphaComponent(0.3), darkColor: UIColor(rgb: 0x384350))
    }
    
    func backgroundTopColor() -> UIColor {
        let lightColor = UIColor(red: 0.39, green: 0.80, blue: 0.86, alpha: 1.0)

        // return self.chooseColor(lightColor: lightColor, darkColor: UIColor(rgb: 0x397CC0))
        return lightColor
    }
    
    func backgroundBottomColor() -> UIColor {
        let lightColor = self.primaryLight()

        // return self.chooseColor(lightColor: self.primaryLight(), darkColor: self.backgroundGrey())
        return lightColor
    }

    func barStyle() -> UIBarStyle {
        return self.useMoonMode ? .black : .default
    }

    func statusBarStyle() -> UIStatusBarStyle {
        return self.useMoonMode ? .lightContent : .default
    }

    func switchMode(isOn: Bool, appRepo: ApplicationRepository) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate

        appRepo.useMoonMode = isOn
        ThemeManager.shared.useMoonMode = isOn
        ThemeManager.shared.initialize(withWindow: appDelegate.window!)

        NotificationCenter.default.post(name: .themeChanged, object: nil)

        let windows = UIApplication.shared.windows as [UIWindow]
        for window in windows {
            let subviews = window.subviews as [UIView]
            for v in subviews {
                v.removeFromSuperview()
                window.addSubview(v)
            }
        }
    }
}

extension UITextField {
    open override func awakeFromNib() {
        super.awakeFromNib()

        NotificationCenter.default.addObserver(self, selector: #selector(themeChanged(notification:)), name: .themeChanged, object: nil)

        self.setPlaceholderColor()
    }

    func setPlaceholderColor() {
        guard let placeholder = self.placeholder else {
            self.attributedPlaceholder = nil
            return
        }

        self.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [
            NSAttributedString.Key.foregroundColor: ThemeManager.shared.placeholderColor()
        ])
    }

    @objc func themeChanged(notification: Notification) {
        self.setPlaceholderColor()
    }
}
