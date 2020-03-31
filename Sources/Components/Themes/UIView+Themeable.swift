//
//  UIView+Themeable.swift
//  VergeiOS
//
//  Created by Ivan Manov on 21.06.2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import Foundation
import UIKit

/// Themeable protocol
@objc protocol Themeable {
    /// Override to setup updating intances
    @objc optional func updateColors()
}

/// Themeable UIView extension
extension UIView: Themeable {

    // MARK: Themeable info

    private static var _themeable = [String: Bool]()
    @IBInspectable var themeable: Bool {
        set(value) {
            UIView._themeable[self.identifier] = value

            self.themeable ? self.subscribe() : self.unsubscribe()
        }
        get {
            return UIView._themeable[self.identifier] ?? false
        }
    }

    var identifier: String {
        return ObjectIdentifier(self).debugDescription
    }

    // MARK: Overrided methods

    open override func awakeFromNib() {
        super.awakeFromNib()

        if self.themeable == true {
            self.updateColors()
        }
    }

    // MARK: Private methods

    func subscribe() {
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(Themeable.updateColors),
            name: .didChangeTheme,
            object: nil
        )
    }

    func unsubscribe() {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: Themeable protocol

    func updateColors() {
    }

    /// Use to become themeable programmatically
    func becomeThemeable() {
        if UIView._themeable.index(forKey: self.identifier) != nil && UIView._themeable[self.identifier] == false {
            return
        }

        self.themeable = true
        self.updateColors()
    }

    /// Use to resign themeable programmatically
    func resignThemeable() {
        self.themeable = false
    }
}

extension UITextField {
    open override func awakeFromNib() {
        super.awakeFromNib()
        super.becomeThemeable()
    }

    override func updateColors() {
        self.textColor = ThemeManager.shared.secondaryDark()
        self.keyboardAppearance = ThemeManager.shared.currentTheme.keyboardAppearance

        guard let placeholder = self.placeholder else {
            self.attributedPlaceholder = nil
            return
        }

        self.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [
            NSAttributedString.Key.foregroundColor: ThemeManager.shared.placeholderColor()
        ])

        self.setNeedsDisplay()
    }
}

extension UITableView {
    open override func awakeFromNib() {
        super.awakeFromNib()
        super.becomeThemeable()
    }

    override func updateColors() {
        self.backgroundColor = ThemeManager.shared.backgroundGrey()
        self.tintColor = ThemeManager.shared.primaryLight()
        self.separatorColor = ThemeManager.shared.separatorColor()

        self.setNeedsDisplay()
    }
}

extension UIImageView {
    override func updateColors() {
        self.tintColor = ThemeManager.shared.primaryLight()
    }
}

extension RoundedButton {
    override func updateColors() {
        self.backgroundColor = ThemeManager.shared.primaryLight()
    }
}

extension UIPageControl {
    open override func awakeFromNib() {
        super.awakeFromNib()
        super.becomeThemeable()
    }

    override func updateColors() {
        self.currentPageIndicatorTintColor = ThemeManager.shared.primaryLight()
        self.pageIndicatorTintColor = ThemeManager.shared.vergeGrey()
    }
}

extension UITableViewCell {
    open override func awakeFromNib() {
        super.awakeFromNib()
        super.becomeThemeable()
    }

    override func updateColors() {
        self.setSelected(false, animated: false)

        let colorView = UIView()
        colorView.backgroundColor = ThemeManager.shared.backgroundBlue()
        self.selectedBackgroundView = colorView
        self.backgroundColor = ThemeManager.shared.backgroundWhite()

        self.textLabel?.textColor = ThemeManager.shared.secondaryDark()
        self.textLabel?.backgroundColor = .clear
        self.detailTextLabel?.textColor = ThemeManager.shared.primaryLight()
        self.detailTextLabel?.backgroundColor = .clear

        self.textLabel?.setNeedsDisplay()
        self.detailTextLabel?.setNeedsDisplay()
        self.setNeedsDisplay()
    }

    func updateFonts() {
        self.textLabel?.font = UIFont.avenir(size: 17).demiBold()
        self.detailTextLabel?.font = UIFont.avenir(size: 12)
    }
}

extension UIActivityIndicatorView {
    open override func awakeFromNib() {
        super.awakeFromNib()
        super.becomeThemeable()
    }

    override func updateColors() {
        self.tintColor = ThemeManager.shared.primaryLight()
    }
}

extension UIButton {
    open override func awakeFromNib() {
        super.awakeFromNib()
        super.becomeThemeable()
    }

    override func updateColors() {
        self.tintColor = ThemeManager.shared.primaryLight()
    }
}

extension UIRefreshControl {
    override func updateColors() {
        self.tintColor = ThemeManager.shared.primaryLight()
    }
}

extension UILabel {
    override func updateColors() {
        self.textColor = ThemeManager.shared.secondaryDark()
    }
}

extension UITabBar {
    open override func awakeFromNib() {
        super.awakeFromNib()
        super.becomeThemeable()
    }

    override func updateColors() {
        self.layer.borderWidth = 0
        self.layer.borderColor = UIColor.clear.cgColor
        self.clipsToBounds = true

        self.tintColor = ThemeManager.shared.primaryLight()
        self.unselectedItemTintColor = ThemeManager.shared.vergeGrey()
        self.barTintColor = ThemeManager.shared.backgroundGrey()
        self.backgroundColor = ThemeManager.shared.backgroundGrey()
        self.barStyle = ThemeManager.shared.barStyle()
        self.isTranslucent = ThemeManager.shared.currentTheme.isTranslucent

        self.setNeedsDisplay()
    }
}

extension UIToolbar {
    open override func awakeFromNib() {
        super.awakeFromNib()
        super.becomeThemeable()
    }

    override func updateColors() {
        self.tintColor = ThemeManager.shared.primaryLight()
        self.barTintColor = ThemeManager.shared.backgroundWhite()
        self.backgroundColor = ThemeManager.shared.backgroundWhite()
        self.barStyle = ThemeManager.shared.barStyle()
        self.isTranslucent = ThemeManager.shared.currentTheme.isTranslucent

        self.setNeedsDisplay()
    }
}

extension UISearchBar {
    open override func awakeFromNib() {
        super.awakeFromNib()
        super.becomeThemeable()
    }

    override func updateColors() {
        self.keyboardAppearance = ThemeManager.shared.currentTheme.keyboardAppearance

        self.setNeedsDisplay()
    }
}

extension CloseButton {
    open override func awakeFromNib() {
        super.awakeFromNib()
        super.becomeThemeable()
    }

    override func updateColors() {
        self.titleLabel?.textColor = ThemeManager.shared.secondaryDark()
        self.tintColor = ThemeManager.shared.secondaryDark()

        self.setNeedsDisplay()
    }
}

extension UIWindow {
    open override func awakeFromNib() {
        super.awakeFromNib()
        super.becomeThemeable()
    }

    override func updateColors() {
        self.tintColor = ThemeManager.shared.primaryLight()

//        self.setNeedsDisplay()
    }
}

extension UINavigationBar {
    override func updateColors() {
        self.setValue(true, forKey: "hidesShadow")

        let font = UIFont.avenir(size: 19).medium()

        self.shadowImage = UIImage()
        self.tintColor = ThemeManager.shared.primaryLight()
        self.barTintColor = ThemeManager.shared.backgroundGrey()
        self.backgroundColor = ThemeManager.shared.backgroundGrey()
        self.barStyle = ThemeManager.shared.barStyle()
        self.isTranslucent = false
        self.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: ThemeManager.shared.secondaryDark(),
            kCTFontAttributeName: font
            ] as? [NSAttributedString.Key: Any]

        self.setNeedsDisplay()
    }
}

extension UISwitch {
    override func updateColors() {
        self.onTintColor = ThemeManager.shared.primaryLight()
        self.setNeedsDisplay()
    }
}
