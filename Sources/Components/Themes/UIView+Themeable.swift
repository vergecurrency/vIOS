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
        self.backgroundColor = ThemeManager.shared.backgroundGrey()
        self.textColor = ThemeManager.shared.secondaryDark()
        self.tintColor = ThemeManager.shared.primaryLight()
        self.keyboardAppearance = ThemeManager.shared.currentTheme.keyboardAppearance
        self.layer.borderColor = ThemeManager.shared.primaryLight().withAlphaComponent(0.5).cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 6
        self.clipsToBounds = true

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
        self.setTitleColor(ThemeManager.shared.backgroundGrey(), for: .normal)
        self.tintColor = ThemeManager.shared.backgroundGrey()
        self.layer.shadowColor = ThemeManager.shared.primaryLight().cgColor
        self.layer.shadowOpacity = 0.25
        self.layer.shadowRadius = 12
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
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
        self.tintColor = ThemeManager.shared.primaryLight()

        self.textLabel?.textColor = ThemeManager.shared.secondaryDark()
        self.textLabel?.backgroundColor = .clear
        self.detailTextLabel?.textColor = ThemeManager.shared.secondaryLight()
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

        let selectedGlowColor = UIColor(rgb: 0xFF3DF2)
        self.tintColor = selectedGlowColor
        self.unselectedItemTintColor = ThemeManager.shared.vergeGreen()
        self.barTintColor = ThemeManager.shared.backgroundGrey()
        self.backgroundColor = ThemeManager.shared.backgroundGrey()
        self.layer.shadowColor = selectedGlowColor.cgColor
        self.layer.shadowOpacity = 0.25
        self.layer.shadowRadius = 18
        self.layer.shadowOffset = CGSize(width: 0, height: -2)
        self.barStyle = ThemeManager.shared.barStyle()
        self.isTranslucent = ThemeManager.shared.currentTheme.isTranslucent
        self.items?.forEach { item in
            item.image = item.image?.withRenderingMode(.alwaysTemplate)
            item.selectedImage = item.selectedImage?.withRenderingMode(.alwaysTemplate)
        }

        if #available(iOS 13.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = ThemeManager.shared.backgroundGrey()
            appearance.shadowColor = .clear

            let selectedAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: selectedGlowColor
            ]
            let normalAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: ThemeManager.shared.vergeGreen()
            ]

            appearance.stackedLayoutAppearance.selected.iconColor = selectedGlowColor
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedAttributes
            appearance.stackedLayoutAppearance.normal.iconColor = ThemeManager.shared.vergeGreen()
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = normalAttributes

            appearance.inlineLayoutAppearance.selected.iconColor = selectedGlowColor
            appearance.inlineLayoutAppearance.selected.titleTextAttributes = selectedAttributes
            appearance.inlineLayoutAppearance.normal.iconColor = ThemeManager.shared.vergeGreen()
            appearance.inlineLayoutAppearance.normal.titleTextAttributes = normalAttributes

            appearance.compactInlineLayoutAppearance.selected.iconColor = selectedGlowColor
            appearance.compactInlineLayoutAppearance.selected.titleTextAttributes = selectedAttributes
            appearance.compactInlineLayoutAppearance.normal.iconColor = ThemeManager.shared.vergeGreen()
            appearance.compactInlineLayoutAppearance.normal.titleTextAttributes = normalAttributes

            self.standardAppearance = appearance
            if #available(iOS 15.0, *) {
                self.scrollEdgeAppearance = appearance
            }
        }

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
        self.layer.shadowColor = ThemeManager.shared.primaryLight().cgColor
        self.layer.shadowOpacity = 0.18
        self.layer.shadowRadius = 12
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
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
