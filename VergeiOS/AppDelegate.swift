//
//  AppDelegate.swift
//  VergeCurrencyWallet
//
//  Created by Swen van Zanten on 06-07-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit
import CoreData
import CoreStore
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var sendRequest: TransactionFactory?
    var backgroundTaskIdentifier: UIBackgroundTaskIdentifier?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        TorStatusIndicator.shared.initialize()
        NotificationManager.shared.initialize()
        ThemeManager.shared.initialize(withWindow: window ?? UIWindow())
        IQKeyboardManager.shared.enable = true
        
        setupListeners()
        
        // Start the tor client
        TorClient.shared.start {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                self.torClientStarted()
            }
        }
        
        WatchSyncManager.shared.startSession()
        
        do {
            CoreStore.defaultStack = DataStack(
                xcodeModelName: "CoreData",
                bundle: Bundle.main,
                migrationChain: [
                    "VergeiOS",
                    "VergeiOS 2"
                ]
            )
            
            try CoreStore.addStorageAndWait(
                SQLiteStore(fileName: "VergeiOS.sqlite", localStorageOptions: .allowSynchronousLightweightMigration)
            )
        } catch {
            print(error.localizedDescription)
        }
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        AddressValidator().validate(string: url.absoluteString) { (valid, address, amount) in
            if !valid {
                return
            }
            
            let transaction = TransactionFactory()
            transaction.address = address!
            transaction.amount = amount ?? 0.0
            
            self.sendRequest = transaction
        }
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        WalletTicker.shared.stop()
        FiatRateTicker.shared.stop()
        
        showPinUnlockViewController(application)
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        TorClient.shared.restart()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        
        // Stop price ticker.
        WalletTicker.shared.stop()
        FiatRateTicker.shared.stop()
    }
    
    func torClientStarted() {
        // Start the price ticker.
        FiatRateTicker.shared.start()
        
        if !ApplicationRepository.default.setup {
            return
        }

        Credentials.shared.setSeed(
            mnemonic: ApplicationRepository.default.mnemonic!,
            passphrase: ApplicationRepository.default.passphrase!
        )

        // Start the wallet ticker.
        WalletTicker.shared.start()
        
        if #available(iOS 12.0, *) {
            IntentsManager.donateIntents()
        }
    }
    
    func showPinUnlockViewController(_ application: UIApplication) {
        if !ApplicationRepository.default.setup {
            return
        }
        
        if var topController = application.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            if let openedPinView = topController as? PinUnlockViewController {
                openedPinView.closeButtonPushed(self)
                
                return showPinUnlockViewController(application)
            }
            
            let vc = PinUnlockViewController.createFromStoryBoard()
            vc.fillPinFor = .wallet
            vc.completion = { authenticated in
                vc.dismiss(animated: true)
                
                // Start the tor client
                TorClient.shared.start {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                        self.torClientStarted()
                    }
                }
            }
            
            print("Show unlock view")
            topController.present(vc, animated: false, completion: nil)
        }
    }
}
