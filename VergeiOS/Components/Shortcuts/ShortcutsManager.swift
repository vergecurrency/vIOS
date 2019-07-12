//
//  ShortcutsManager.swift
//  VergeiOS
//
//  Created by Ivan Manov on 23/03/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import Foundation
import UIKit

class ShortcutsManager: NSObject {

    private var applicationRepository: ApplicationRepository!

    // MARK: Init

    private override init() {}

    init(applicationRepository: ApplicationRepository) {
        self.applicationRepository = applicationRepository
    }

    // MARK: - Types

    enum ShortcutIdentifier: String {
        case website
        case repository
        case send
        case receive

        // MARK: - Initializers

        init?(fullType: String) {
            guard let last = fullType.components(separatedBy: ".").last else { return nil }
            self.init(rawValue: last)
        }

        // MARK: - Properties

        var type: String {
            return Bundle.main.bundleIdentifier! + ".\(self.rawValue)"
        }
    }

    // MARK: - Static Properties

    static let applicationShortcutUserInfoIconKey = "applicationShortcutUserInfoIconKey"

    // MARK: - Properties

    var application: UIApplication?
    var needHandleShortcut: Bool = false
    private(set) var lastShortcutType: String?

    /// Saved shortcut item used as a result of an app launch, used later when app is activated.
    var launchedShortcutItem: UIApplicationShortcutItem?

    // MARK: Public methods

    func handleShortCutItem(_ shortcutItem: UIApplicationShortcutItem) -> Bool {
        var handled = false

        // Verify that the provided `shortcutItem`'s `type` is one handled by the application.
        guard ShortcutIdentifier(fullType: shortcutItem.type) != nil else { return false }

        guard let shortCutType = shortcutItem.type as String? else { return false }
        lastShortcutType = shortCutType

        switch shortCutType {
        case ShortcutIdentifier.website.type:
            UIApplication.shared.open(URL(string: "https://vergecurrency.com")!,
                                      options: [:],
                                      completionHandler: nil)
            handled = true
        case ShortcutIdentifier.repository.type:
            UIApplication.shared.open(URL(string: "https://github.com/vergecurrency/vIOS")!,
                                      options: [:],
                                      completionHandler: nil)
            handled = true
        case ShortcutIdentifier.send.type:
            needHandleShortcut = true
            handled = true
        case ShortcutIdentifier.receive.type:
            needHandleShortcut = true
            handled = true
        default:
            break
        }

        return handled
    }

    // MARK: - Application Life Cycle

    func proceedAppDidFinishLaunch(_ application: UIApplication,
                                   withOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.application = application

        // Override point for customization after application launch.
        var shouldPerformAdditionalDelegateHandling = true

        // If a shortcut was launched, display its information and take the appropriate action.
        if let shortcutItem =
            launchOptions?[UIApplication.LaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem {

            launchedShortcutItem = shortcutItem

            // This will block "performActionForShortcutItem:completionHandler" from being called.
            shouldPerformAdditionalDelegateHandling = false
        }

        updateShortcuts()

        return shouldPerformAdditionalDelegateHandling
    }

    func proceedAppDidBecomeActive() {
        guard let shortcut = launchedShortcutItem else { return }
        _ = handleShortCutItem(shortcut)

        // Reset which shortcut was chosen for next time.
        launchedShortcutItem = nil
    }

    func updateShortcuts() {
        var shortcutItems: [UIApplicationShortcutItem]?

        // Install initial versions of dynamic shortcuts.
        if application!.shortcutItems != nil {
            // Check wallet setup
            let hasWallet = self.applicationRepository.setup

            // Construct dynamic short item #3
            let websiteShortcutUserInfo = [ShortcutsManager.applicationShortcutUserInfoIconKey: "Website"]
            let websiteShortcut =
                UIMutableApplicationShortcutItem(type: ShortcutIdentifier.website.type,
                                                 localizedTitle: "shortcuts.action.website.title".localized,
                                                 localizedSubtitle: nil,
                                                 icon: UIApplicationShortcutIcon(templateImageName: "Development"),
                                                 userInfo: websiteShortcutUserInfo as [String: NSSecureCoding])

            // Construct dynamic short #4
            let repositoryShortcutUserInfo = [ShortcutsManager.applicationShortcutUserInfoIconKey: "Receive"]
            let repositoryShortcut =
                UIMutableApplicationShortcutItem(type: ShortcutIdentifier.repository.type,
                                                 localizedTitle: "shortcuts.action.sourceCode.title".localized,
                                                 localizedSubtitle: nil,
                                                 icon: UIApplicationShortcutIcon(templateImageName: "GitHub"),
                                                 userInfo: repositoryShortcutUserInfo as [String: NSSecureCoding])

            if hasWallet {
                // Construct dynamic short item #1
                let sendShortcutUserInfo = [ShortcutsManager.applicationShortcutUserInfoIconKey: "Send"]
                let sendShortcut =
                    UIMutableApplicationShortcutItem(type: ShortcutIdentifier.send.type,
                                                     localizedTitle: "shortcuts.action.send.title".localized,
                                                     localizedSubtitle: nil,
                                                     icon: UIApplicationShortcutIcon(templateImageName: "Send"),
                                                     userInfo: sendShortcutUserInfo as [String: NSSecureCoding])

                // Construct dynamic short #2
                let receiveShortcutUserInfo = [ShortcutsManager.applicationShortcutUserInfoIconKey: "Receive"]
                let receiveShortcut =
                    UIMutableApplicationShortcutItem(type: ShortcutIdentifier.receive.type,
                                                     localizedTitle: "shortcuts.action.receive.title".localized,
                                                     localizedSubtitle: nil,
                                                     icon: UIApplicationShortcutIcon(templateImageName: "Receive"),
                                                     userInfo: receiveShortcutUserInfo as [String: NSSecureCoding])

                shortcutItems = [sendShortcut, receiveShortcut, websiteShortcut, repositoryShortcut]
            } else {
                shortcutItems = [websiteShortcut, repositoryShortcut]
            }

            // Update the application providing the initial 'dynamic' shortcut items.
            application!.shortcutItems = shortcutItems
        }
    }
}
