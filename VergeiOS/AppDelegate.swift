//
//  AppDelegate.swift
//  VergeCurrencyWallet
//
//  Created by Swen van Zanten on 06-07-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit
import Swinject
import SwinjectStoryboard
import Logging

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var application: Application?
    var window: UIWindow?
    var sendRequest: WalletTransactionFactory?
    var backgroundTaskIdentifier: UIBackgroundTaskIdentifier?

    var log: Logger? {
        return Application.container?.resolve(Logger.self)
    }

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        self.application = Application(container: SwinjectStoryboard.defaultContainer)
        self.application?.boot()
        UIAlertController.installRetrowavePresenter()
        installRetrowaveBarAppearance()

        self.log?.info("app delegate application did finish launching")

        // Resolve ShortcutsManager safely
        guard let shortcutsManager = Application.container.resolve(ShortcutsManager.self) else {
            print("❌ ShortcutsManager not registered in container")
            return false // or true depending on your app logic
        }

        // Now it's safe to use
        let shouldPerformAdditionalDelegateHandling = shortcutsManager.proceedAppDidFinishLaunch(
            application,
            withOptions: launchOptions
        )

        return shouldPerformAdditionalDelegateHandling

    }

    private func installRetrowaveBarAppearance() {
        let pink = UIColor(rgb: 0xFF3DF2)
        let buttonColor = UIColor.white
        let title = UIColor.white
        let background = ThemeManager.shared.backgroundGrey()
        let titleFont = UIFont.avenir(size: 19).medium()
        let buttonFont = UIFont.avenir(size: 14).demiBold()

        UIBarButtonItem.appearance().tintColor = buttonColor
        UIBarButtonItem.appearance().setTitleTextAttributes([
            .foregroundColor: buttonColor,
            .font: buttonFont
        ], for: .normal)
        UIBarButtonItem.appearance().setTitleTextAttributes([
            .foregroundColor: pink,
            .font: buttonFont
        ], for: .highlighted)

        if #available(iOS 13.0, *) {
            let navAppearance = UINavigationBarAppearance()
            navAppearance.configureWithOpaqueBackground()
            navAppearance.backgroundColor = background
            navAppearance.shadowColor = .clear
            navAppearance.titleTextAttributes = [
                .foregroundColor: title,
                .font: titleFont
            ]
            navAppearance.largeTitleTextAttributes = [
                .foregroundColor: title,
                .font: UIFont.avenir(size: 28).demiBold()
            ]

            let barButtonAppearance = UIBarButtonItemAppearance(style: .plain)
            barButtonAppearance.normal.titleTextAttributes = [
                .foregroundColor: buttonColor,
                .font: buttonFont
            ]
            barButtonAppearance.highlighted.titleTextAttributes = [
                .foregroundColor: pink,
                .font: buttonFont
            ]
            barButtonAppearance.disabled.titleTextAttributes = [
                .foregroundColor: ThemeManager.shared.secondaryLight(),
                .font: buttonFont
            ]
            navAppearance.buttonAppearance = barButtonAppearance
            navAppearance.doneButtonAppearance = barButtonAppearance
            navAppearance.backButtonAppearance = barButtonAppearance

            UINavigationBar.appearance().standardAppearance = navAppearance
            UINavigationBar.appearance().compactAppearance = navAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
            UINavigationBar.appearance().tintColor = buttonColor
        } else {
            UINavigationBar.appearance().barTintColor = background
            UINavigationBar.appearance().tintColor = buttonColor
            UINavigationBar.appearance().titleTextAttributes = [
                .foregroundColor: title,
                .font: titleFont
            ]
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state.
        // This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message)
        // or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks.
        // Games should use this method to pause the game.
        self.log?.info("app delegate application will resign active")
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers,
        // and store enough application state information to restore your application
        // to its current state in case it is terminated later.
        // If your application supports background execution, this method is called
        // instead of applicationWillTerminate: when the user quits.

        // Show pincode
        self.showPinUnlockViewController(application)

        // Stop wallet ticker.
        Application.container.resolve(WalletTicker.self)?.stop()

        // Stop fiat rate ticker.
        Application.container.resolve(FiatRateTicker.self)?.stop()

        self.log?.info("app delegate application did enter background")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state;
        // here you can undo many of the changes made on entering the background.

        // Restart Tor.
        Application.container.resolve(TorClientProtocol.self)?.restart()

        self.log?.info("app delegate application will enter foreground")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive.
        // If the application was previously in the background, optionally refresh the user interface.
        self.log?.info("app delegate application did become active")

        Application.container.resolve(ShortcutsManager.self)?.proceedAppDidBecomeActive()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate.
        // See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.log?.info("app delegate application will terminate")

        // Stop wallet ticker.
        Application.container.resolve(WalletTicker.self)?.stop()

        // Stop fiat rate ticker.
        Application.container.resolve(FiatRateTicker.self)?.stop()
    }

    func showPinUnlockViewController(_ application: UIApplication) {
        let appRepo = Application.container.resolve(ApplicationRepository.self)!
        if !appRepo.setup {
            return
        }

        let keyWindow = application.windows.filter {$0.isKeyWindow}.first

        if var topController = keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }

            if let openedPinView = topController as? PinUnlockViewController {
                openedPinView.closeButtonPushed(self)

                return self.showPinUnlockViewController(application)
            }

            let vc = PinUnlockViewController.createFromStoryBoard()
            vc.fillPinFor = .wallet
            vc.completion = { authenticated in
                vc.dismiss(animated: true)
            }

            topController.present(vc, animated: false)

            self.log?.info("app delegate show unlock view")

            return
        }

        fatalError("No window found to present the pin unlock view over!")
    }

    /*
     Called when the user activates your application by selecting a shortcut on the home screen, except when
     application(_:,willFinishLaunchingWithOptions:) or application(_:didFinishLaunchingWithOptions) returns `false`.
     You should handle the shortcut in those callbacks and return `false` if possible. In that case, this
     callback is used if your application is already launched in the background.
     */
    func application(
        _ application: UIApplication,
        performActionFor shortcutItem: UIApplicationShortcutItem,
        completionHandler: @escaping (Bool) -> Void
    ) {
        self.log?.info("app delegate application perform action for shortcut item")

        let shortcutsManager = Application.container.resolve(ShortcutsManager.self)!
        let handledShortCutItem = shortcutsManager.handleShortCutItem(shortcutItem)

        completionHandler(handledShortCutItem)
    }

    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        self.log?.info("app delegate application open url")

        self.sendTxRequest(address: url.absoluteString)

        return true
    }

    func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?
    ) -> Void) -> Bool {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb else {
            return false
        }

        let ndefMessage = userActivity.ndefMessagePayload
        guard
            #available(iOS 13.0, *),
            ndefMessage.records.count > 0,
            ndefMessage.records[0].typeNameFormat != .empty
        else {
            return false
        }

        guard let payload = ndefMessage.records.first, payload.typeNameFormat == .nfcWellKnown else {
            return false
        }

        guard let url = payload.wellKnownTypeURIPayload()?.absoluteString else {
            return false
        }

        self.log?.info("app delegate application opened associated domain")

        self.sendTxRequest(address: url)

        return true
    }

    private func sendTxRequest(address: String) {
        AddressValidator().validateOrResolve(string: address) { (valid, address, amount, label, currency) in
            if !valid {
                return
            }

            let transaction = Application.container.resolve(WalletTransactionFactory.self)!
            transaction.address = address!
            transaction.memo = label ?? ""

            if (currency == "XVG" || currency == nil) {
                transaction.amount = amount ?? 0.0
            } else {
                transaction.fiatAmount = amount ?? 0.0
            }

            if let currency = currency {
                transaction.fiatCurrency = currency
                transaction.currency = .FIAT
            }

            self.sendRequest = transaction

            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .demandSendView, object: transaction)
            }
        }
    }
}
