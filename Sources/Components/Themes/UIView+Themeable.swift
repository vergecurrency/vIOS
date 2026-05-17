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

private extension UIButton {
    var hasVisibleTitle: Bool {
        return !(title(for: .normal)?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
    }

    func applyRetrowaveButtonStyle(force: Bool) {
        if self is KeyboardButton {
            return
        }

        guard force || hasVisibleTitle else {
            return
        }

        setTitleColor(.white, for: .normal)
        setTitleColor(UIColor.white.withAlphaComponent(0.78), for: .disabled)
        setTitleColor(ThemeManager.shared.primaryLight(), for: .highlighted)
        tintColor = .white
        backgroundColor = .clear
        layer.cornerRadius = 8
        layer.borderWidth = 1
        layer.borderColor = UIColor(rgb: 0xFF3DF2).withAlphaComponent(0.7).cgColor
        layer.shadowColor = UIColor(rgb: 0xFF3DF2).cgColor
        layer.shadowOpacity = 0.35
        layer.shadowRadius = 12
        layer.shadowOffset = CGSize(width: 0, height: 0)
        clipsToBounds = false
        contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        imageEdgeInsets = UIEdgeInsets(top: 0, left: -2, bottom: 0, right: 6)
        titleEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: -2)
        titleLabel?.adjustsFontSizeToFitWidth = true
        titleLabel?.minimumScaleFactor = 0.82
        titleLabel?.textAlignment = .center

        applyRetrowaveGradient()
        animateRetrowaveGlow()
        if let imageView = imageView {
            bringSubviewToFront(imageView)
        }
        if let titleLabel = titleLabel {
            bringSubviewToFront(titleLabel)
        }
    }

    func applyRetrowaveGradient() {
        let gradientName = "RetrowaveButtonGradient"
        layer.sublayers?
            .filter { $0.name == gradientName }
            .forEach { $0.removeFromSuperlayer() }

        guard bounds.width > 0 && bounds.height > 0 else {
            DispatchQueue.main.async { [weak self] in
                self?.applyRetrowaveGradient()
            }
            return
        }

        let gradient = CAGradientLayer()
        gradient.name = gradientName
        gradient.frame = bounds
        gradient.cornerRadius = layer.cornerRadius
        gradient.colors = [
            UIColor(rgb: 0x14071F).cgColor,
            UIColor(rgb: 0x3A125C).cgColor,
            UIColor(rgb: 0x12071A).cgColor
        ]
        gradient.locations = [0.0, 0.52, 1.0]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        layer.insertSublayer(gradient, at: 0)
    }

    func animateRetrowaveGlow() {
        let key = "RetrowaveButtonGlow"
        guard layer.animation(forKey: key) == nil else {
            return
        }

        let animation = CABasicAnimation(keyPath: "shadowOpacity")
        animation.fromValue = 0.2
        animation.toValue = 0.55
        animation.duration = 1.45
        animation.autoreverses = true
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        layer.add(animation, forKey: key)
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

extension UITextView {
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
        self.applyRetrowaveButtonStyle(force: true)
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
        self.contentView.backgroundColor = ThemeManager.shared.backgroundWhite()
        self.tintColor = ThemeManager.shared.primaryLight()
        self.layer.cornerRadius = 8
        self.layer.borderWidth = 1
        self.layer.borderColor = ThemeManager.shared.primaryLight().withAlphaComponent(0.18).cgColor
        self.layer.shadowColor = ThemeManager.shared.primaryLight().cgColor
        self.layer.shadowOpacity = 0.08
        self.layer.shadowRadius = 6
        self.layer.shadowOffset = CGSize(width: 0, height: 0)

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

    open override func layoutSubviews() {
        super.layoutSubviews()

        if hasVisibleTitle && !(self is KeyboardButton) {
            applyRetrowaveButtonStyle(force: false)
        }
    }

    override func updateColors() {
        self.tintColor = ThemeManager.shared.primaryLight()

        if hasVisibleTitle && !(self is KeyboardButton) {
            applyRetrowaveButtonStyle(force: false)
        }
    }
}

extension UIRefreshControl {
    override func updateColors() {
        self.tintColor = ThemeManager.shared.primaryLight()
    }
}

extension UILabel {
    open override func awakeFromNib() {
        super.awakeFromNib()
        super.becomeThemeable()
    }

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
                .foregroundColor: selectedGlowColor,
                .font: UIFont.avenir(size: 10).demiBold()
            ]
            let normalAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: ThemeManager.shared.vergeGreen(),
                .font: UIFont.avenir(size: 10).demiBold()
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
        self.barStyle = ThemeManager.shared.barStyle()
        self.tintColor = ThemeManager.shared.primaryLight()
        self.barTintColor = ThemeManager.shared.backgroundGrey()

        if #available(iOS 13.0, *) {
            self.searchTextField.backgroundColor = ThemeManager.shared.backgroundWhite()
            self.searchTextField.textColor = ThemeManager.shared.secondaryDark()
            self.searchTextField.tintColor = ThemeManager.shared.primaryLight()
            self.searchTextField.attributedPlaceholder = NSAttributedString(
                string: self.searchTextField.placeholder ?? "",
                attributes: [.foregroundColor: ThemeManager.shared.placeholderColor()]
            )
        }

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
        let titleColor = ThemeManager.shared.secondaryDark()
        let buttonColor = ThemeManager.shared.primaryLight()

        self.shadowImage = UIImage()
        self.tintColor = buttonColor
        self.barTintColor = ThemeManager.shared.backgroundGrey()
        self.backgroundColor = ThemeManager.shared.backgroundGrey()
        self.layer.shadowColor = buttonColor.cgColor
        self.layer.shadowOpacity = 0.18
        self.layer.shadowRadius = 12
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.barStyle = ThemeManager.shared.barStyle()
        self.isTranslucent = false
        self.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: titleColor,
            kCTFontAttributeName: font
            ] as? [NSAttributedString.Key: Any]

        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = ThemeManager.shared.backgroundGrey()
            appearance.shadowColor = .clear
            appearance.titleTextAttributes = [
                .foregroundColor: titleColor,
                .font: font
            ]
            appearance.largeTitleTextAttributes = [
                .foregroundColor: titleColor,
                .font: UIFont.avenir(size: 28).demiBold()
            ]

            let buttonAppearance = UIBarButtonItemAppearance(style: .plain)
            let buttonAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: buttonColor,
                .font: UIFont.avenir(size: 14).demiBold()
            ]
            buttonAppearance.normal.titleTextAttributes = buttonAttributes
            buttonAppearance.highlighted.titleTextAttributes = [
                .foregroundColor: UIColor(rgb: 0xFF3DF2),
                .font: UIFont.avenir(size: 14).demiBold()
            ]
            buttonAppearance.disabled.titleTextAttributes = [
                .foregroundColor: ThemeManager.shared.secondaryLight(),
                .font: UIFont.avenir(size: 14).demiBold()
            ]
            appearance.buttonAppearance = buttonAppearance
            appearance.doneButtonAppearance = buttonAppearance
            appearance.backButtonAppearance = buttonAppearance

            self.standardAppearance = appearance
            self.compactAppearance = appearance
            self.scrollEdgeAppearance = appearance
        }

        self.setNeedsDisplay()
    }
}

extension UISwitch {
    override func updateColors() {
        self.onTintColor = ThemeManager.shared.primaryLight()
        self.setNeedsDisplay()
    }
}
