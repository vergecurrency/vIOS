//
//  MainTabBarController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 23-09-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit
import SwiftyJSON

class MainTabBarController: UITabBarController {

    let sendViewIndex: Int = 2
    let receiveViewIndex: Int = 3

    var applicationRepository: ApplicationRepository!
    var shortcutsManager: ShortcutsManager!

    override func viewDidLoad() {
        super.viewDidLoad()

        applyRetrowaveTabStyling()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(demandSendView(notification:)),
            name: .demandSendView,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didDeviceShaken(notification:)),
            name: .didDeviceShaken,
            object: nil
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        applyRetrowaveTabStyling()

        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            if let sendTransaction = delegate.sendRequest {
                // Prepare the send view with the transaction.
                prepareSendView(transaction: sendTransaction)

                // Remove the transaction from the delegate.
                delegate.sendRequest = nil
            } else if self.shortcutsManager.needHandleShortcut {
                proceedShortcut()
                self.shortcutsManager.needHandleShortcut = false
            }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        applyRetrowaveTabStyling()
    }

    private func applyRetrowaveTabStyling() {
        let normalColor = ThemeManager.shared.vergeGreen()
        let selectedColor = UIColor(rgb: 0xFF3DF2)

        tabBar.tintColor = selectedColor
        tabBar.unselectedItemTintColor = normalColor
        tabBar.barTintColor = ThemeManager.shared.backgroundGrey()
        tabBar.backgroundColor = ThemeManager.shared.backgroundGrey()
        tabBar.layer.shadowColor = selectedColor.cgColor
        tabBar.layer.shadowOpacity = 0.25
        tabBar.layer.shadowRadius = 18
        tabBar.layer.shadowOffset = CGSize(width: 0, height: -2)

        tabBar.items?.forEach { item in
            if let image = item.image {
                item.image = image
                    .withRenderingMode(.alwaysTemplate)
                    .withTintColor(normalColor, renderingMode: .alwaysOriginal)
            }
            if let selectedImage = item.selectedImage ?? item.image {
                item.selectedImage = selectedImage
                    .withRenderingMode(.alwaysTemplate)
                    .withTintColor(selectedColor, renderingMode: .alwaysOriginal)
            }
            item.setTitleTextAttributes([.foregroundColor: normalColor], for: .normal)
            item.setTitleTextAttributes([.foregroundColor: selectedColor], for: .selected)
        }

        if #available(iOS 13.0, *) {
            let selectedAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: selectedColor]
            let normalAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: normalColor]
            let appearance = tabBar.standardAppearance.copy() as! UITabBarAppearance

            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = ThemeManager.shared.backgroundGrey()
            appearance.shadowColor = .clear

            [appearance.stackedLayoutAppearance, appearance.inlineLayoutAppearance, appearance.compactInlineLayoutAppearance].forEach { itemAppearance in
                itemAppearance.normal.iconColor = normalColor
                itemAppearance.normal.titleTextAttributes = normalAttributes
                itemAppearance.selected.iconColor = selectedColor
                itemAppearance.selected.titleTextAttributes = selectedAttributes
                itemAppearance.focused.iconColor = selectedColor
                itemAppearance.focused.titleTextAttributes = selectedAttributes
            }

            tabBar.standardAppearance = appearance
            if #available(iOS 15.0, *) {
                tabBar.scrollEdgeAppearance = appearance
            }
        }
    }

    func proceedShortcut() {
        let shortCutType = self.shortcutsManager.lastShortcutType
        switch shortCutType {
        case ShortcutsManager.ShortcutIdentifier.send.type:
            selectedIndex = sendViewIndex
        case ShortcutsManager.ShortcutIdentifier.receive.type:
            selectedIndex = receiveViewIndex
        default:
            break
        }
    }

    func prepareSendView(transaction: WalletTransactionFactory) {
        // Select the send view.
        selectedIndex = sendViewIndex

        guard let navigationController = viewControllers?[sendViewIndex] as? UINavigationController else {
            return
        }

        guard let sendViewController = navigationController.viewControllers.first as? SendViewController else {
            return
        }

        // Set the transaction on the send view.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            sendViewController.didChangeSendTransaction(transaction)
        }
    }

    @objc func demandSendView(notification: Notification) {
        if let sendTransaction = notification.object as? WalletTransactionFactory {
            self.prepareSendView(transaction: sendTransaction)
        }
    }

    @objc func didDeviceShaken(notification: Notification? = nil) {
        self.applicationRepository.secureContent = !self.applicationRepository.secureContent
    }
}
