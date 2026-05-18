//
// Created by Swen van Zanten on 25/10/2018.
// Copyright (c) 2018 Verge Currency. All rights reserved.
//

import UIKit
import ObjectiveC

extension UIAlertController {
    private static var hasInstalledRetrowavePresenter = false

    static func installRetrowavePresenter() {
        guard !hasInstalledRetrowavePresenter else {
            return
        }

        hasInstalledRetrowavePresenter = true
        UIViewController.installRetrowaveAlertPresenter()
    }

    func applyRetrowaveTheme() {
        if let title = title {
            let paragraph = NSMutableParagraphStyle()
            paragraph.alignment = .center
            setValue(NSAttributedString(
                string: title,
                attributes: [
                    .foregroundColor: UIColor.white,
                    .font: UIFont.systemFont(ofSize: 17, weight: .semibold),
                    .paragraphStyle: paragraph
                ]
            ), forKey: "attributedTitle")
        }

        if let message = message {
            let paragraph = NSMutableParagraphStyle()
            paragraph.alignment = .center
            setValue(NSAttributedString(
                string: message,
                attributes: [
                    .foregroundColor: ThemeManager.shared.secondaryLight(),
                    .font: UIFont.systemFont(ofSize: 14, weight: .regular),
                    .paragraphStyle: paragraph
                ]
            ), forKey: "attributedMessage")
        }

        actions.forEach { action in
            let color: UIColor = action.style == .destructive
                ? ThemeManager.shared.vergeRed()
                : .white
            action.setValue(color, forKey: "titleTextColor")
        }

        view.tintColor = ThemeManager.shared.primaryLight()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 14
        view.layer.shadowColor = UIColor(rgb: 0xFF3DF2).cgColor
        view.layer.shadowOpacity = 0.4
        view.layer.shadowRadius = 24
        view.layer.shadowOffset = CGSize(width: 0, height: 0)

        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }

            self.styleRetrowaveAlertView(self.view)
            self.addRetrowaveAlertGradient(to: self.view)
        }
    }

    private func styleRetrowaveAlertView(_ root: UIView) {
        root.subviews.forEach { styleRetrowaveAlertView($0) }

        if let label = root as? UILabel {
            label.textColor = .white
            if label.font.pointSize < 15 {
                label.textColor = ThemeManager.shared.secondaryLight()
            }
        }

        if let textField = root as? UITextField {
            textField.updateColors()
        }

        if let visualEffect = root as? UIVisualEffectView {
            visualEffect.effect = nil
            visualEffect.backgroundColor = .clear
        } else if root !== view {
            root.backgroundColor = root.backgroundColor == nil || root.backgroundColor == .clear
                ? .clear
                : UIColor(rgb: 0x150A24).withAlphaComponent(0.96)
        }
    }

    private func addRetrowaveAlertGradient(to root: UIView) {
        let gradientName = "RetrowaveAlertGradient"
        root.layer.sublayers?
            .filter { $0.name == gradientName }
            .forEach { $0.removeFromSuperlayer() }

        guard root.bounds.width > 0 && root.bounds.height > 0 else {
            return
        }

        let gradient = CAGradientLayer()
        gradient.name = gradientName
        gradient.frame = root.bounds
        gradient.cornerRadius = 14
        gradient.colors = [
            UIColor(rgb: 0x05020B).cgColor,
            UIColor(rgb: 0x24103A).cgColor,
            UIColor(rgb: 0x07030E).cgColor
        ]
        gradient.locations = [0.0, 0.55, 1.0]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        root.layer.insertSublayer(gradient, at: 0)
    }

    static func createWalletSetupErrorAlert(
        error: String,
        handler: @escaping (UIAlertAction) -> Void
    ) -> UIAlertController {
        let alert = UIAlertController(
            title: "alerts.walletSetup.title".localized,
            message: "\("alerts.walletSetup.message".localized): \(error)",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "defaults.ok".localized, style: .cancel))
        alert.addAction(UIAlertAction(title: "settings.other.cell.supportLabel".localized, style: .default, handler: handler))

        return alert
    }

    static func createDeleteContactAlert(handler: ((UIAlertAction) -> Void)?) -> UIAlertController {
        let alert = UIAlertController(
            title: "alerts.removeContact.title".localized,
            message: "alerts.removeContact.message".localized,
            preferredStyle: .alert
        )

        let delete = UIAlertAction(title: "defaults.delete".localized, style: .destructive, handler: handler)

        alert.addAction(UIAlertAction(title: "defaults.cancel".localized, style: .cancel))
        alert.addAction(delete)

        return alert
    }

    static func createInvalidContactAlert() -> UIAlertController {
        let alert = UIAlertController(
            title: "alerts.invalidContact.title".localized,
            message: "alerts.invalidContact.message".localized,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "defaults.ok".localized, style: .cancel))

        return alert
    }

    static func createDeleteTransactionAlert(handler: ((UIAlertAction) -> Void)?) -> UIAlertController {
        let alert = UIAlertController(
            title: "alerts.removeTransaction.title".localized,
            message: "alerts.removeTransaction.message".localized,
            preferredStyle: .alert
        )

        let delete = UIAlertAction(title: "defaults.delete".localized, style: .destructive, handler: handler)

        alert.addAction(UIAlertAction(title: "defaults.cancel".localized, style: .cancel))
        alert.addAction(delete)

        return alert
    }

    static func createAddressGapReachedAlert() -> UIAlertController {
        let alert = UIAlertController(
            title: "alerts.createAddress.title".localized,
            message: "alerts.createAddress.message".localized,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "defaults.ok".localized, style: .cancel))

        return alert
    }

    static func createSendMaxInfoAlert() -> UIAlertController {
        let alert = UIAlertController(
            title: "alerts.sendMaxInfo.title".localized,
            message: "alerts.sendMaxInfo.message".localized,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "defaults.ok".localized, style: .cancel))

        return alert
    }

    static func createStartTorActionSheet() -> UIAlertController {
        let actionSheet = UIAlertController(
            title: "alerts.startTor.title".localized,
            message: "alerts.startTor.message".localized,
            preferredStyle: .actionSheet
        )

        actionSheet.addAction(UIAlertAction(title: "alerts.startTor.button1".localized, style: .default))
        actionSheet.addAction(UIAlertAction(title: "alerts.startTor.button2".localized, style: .destructive))
        actionSheet.addAction(UIAlertAction(title: "defaults.cancel".localized, style: .cancel))

        return actionSheet
    }

    static func createShowTermsOfUseAlert() -> UIAlertController {
        let alert = UIAlertController(title: "alerts.termsOfUse.title".localized, message: nil, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "defaults.cancel".localized, style: .cancel))
        alert.addAction(UIAlertAction(title: "defaults.open".localized, style: .default) { _ in
            if let path: URL = URL(string: Constants.termsOfUse) {
                UIApplication.shared.open(path, options: [:])
            }
        })

        return alert
    }

    static func createNotEnoughBalanceAlert() -> UIAlertController {
        let alert = UIAlertController(
            title: "alerts.notEnoughBalance.title".localized,
            message: "alerts.notEnoughBalance.message".localized,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "defaults.ok".localized, style: .default))

        return alert
    }

    static func createInvalidPrivateKeyAlert() -> UIAlertController {
        let alert = UIAlertController(
            title: "alerts.invalidPrivateKey.title".localized,
            message: "alerts.invalidPrivateKey.message".localized,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "defaults.ok".localized, style: .default))

        return alert
    }

    static func createInvalidMnemonicAlert() -> UIAlertController {
        let alert = UIAlertController(
            title: "alerts.invalidMnemonic.title".localized,
            message: "alerts.invalidMnemonic.message".localized,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "defaults.ok".localized, style: .default))

        return alert
    }
    
    static func createTxNotAcceptedAlert() -> UIAlertController {
        let alert = UIAlertController(
            title: "alerts.txNotAccepted.title".localized,
            message: "alerts.txNotAccepted.message".localized,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "defaults.ok".localized, style: .default))
        
        return alert
    }

    static func createNoTxIDAlert() -> UIAlertController {
        let alert = UIAlertController(
            title: "alerts.noTxID.title".localized,
            message: "alerts.noTxID.message".localized,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "defaults.ok".localized, style: .default))

        return alert
    }

    static func createUnexpectedErrorAlert(error: Error) -> UIAlertController {
        let alert = UIAlertController(
            title: "alerts.unexpectedError.title".localized,
            message: "alerts.unexpectedError.message".localized + " \(error.localizedDescription)",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "defaults.ok".localized, style: .default))

        return alert
    }

    static func restartAlert() -> UIAlertController {
        let alert = UIAlertController(title: "alerts.restart.title".localized, message: nil, preferredStyle: .alert)

        return alert
    }

    static func loadingAlert(title: String = "alerts.loading.title".localized) -> UIAlertController {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)

        return alert
    }

    func centerPopoverController(to view: UIView) {
        if let popoverController = self.popoverPresentationController {
            popoverController.sourceView = view
            popoverController.sourceRect = CGRect(
                x: view.bounds.midX,
                y: view.bounds.midY,
                width: 0,
                height: 0
            )

            popoverController.permittedArrowDirections = []
        }
    }
}

private extension UIViewController {
    static func installRetrowaveAlertPresenter() {
        let original = class_getInstanceMethod(
            UIViewController.self,
            #selector(UIViewController.present(_:animated:completion:))
        )
        let swizzled = class_getInstanceMethod(
            UIViewController.self,
            #selector(UIViewController.retrowavePresent(_:animated:completion:))
        )

        guard let originalMethod = original, let swizzledMethod = swizzled else {
            return
        }

        method_exchangeImplementations(originalMethod, swizzledMethod)
    }

    @objc func retrowavePresent(
        _ viewControllerToPresent: UIViewController,
        animated flag: Bool,
        completion: (() -> Void)? = nil
    ) {
        if let alert = viewControllerToPresent as? UIAlertController {
            alert.applyRetrowaveTheme()
        }

        retrowavePresent(viewControllerToPresent, animated: flag, completion: completion)
    }
}
