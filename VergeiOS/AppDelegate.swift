//
//  AppDelegate.swift
//  VergeCurrencyWallet
//
//  Created by Swen van Zanten on 06-07-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit
import CoreData
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var sendRequest: SendTransaction?
    var backgroundTaskIdentifier: UIBackgroundTaskIdentifier?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        TorStatusIndicator.shared.initialize()
        
        backgroundTaskIdentifier = application.beginBackgroundTask {
            if self.backgroundTaskIdentifier != nil {
                application.endBackgroundTask(self.backgroundTaskIdentifier!)
            }
        }
        
        registerAppforDetectLockState()
        setupListeners()
        
        // Start the tor client
        TorClient.shared.start {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                // Start the price ticker.
                PriceTicker.shared.start()
                
                let loadingViewController = self.window?.rootViewController as! LoadingTorViewController
                loadingViewController.completeLoading()
            }
        }

        IQKeyboardManager.shared.enable = true
        
        UITabBar.appearance().layer.borderWidth = 0
        UITabBar.appearance().layer.borderColor = UIColor.clear.cgColor
        UITabBar.appearance().clipsToBounds = true

        window?.tintColor = UIColor.primaryLight()

        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        AddressValidator().validate(string: url.absoluteString) { (valid, address, amount) in
            if !valid {
                return
            }
            
            let transaction = SendTransaction()
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
        PriceTicker.shared.stop()

        showPinUnlockViewController()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
        // Start the tor client
        TorClient.shared.start {
            // Start the price ticker.
            PriceTicker.shared.start()
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
        
        // Stop price ticker.
        PriceTicker.shared.stop()
        TorClient.shared.resign()
    }

    func setupListeners() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didStartTorThread(notification:)),
            name: .didStartTorThread,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didEstablishTorConnection(notification:)),
            name: .didEstablishTorConnection,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didResignTorConnection(notification:)),
            name: .didResignTorConnection,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didTurnOffTor(notification:)),
            name: .didTurnOffTor,
            object: nil
        )
    }

    @objc func didStartTorThread(notification: Notification? = nil) {
        TorStatusIndicator.shared.setStatus(.disconnected)
    }

    @objc func didEstablishTorConnection(notification: Notification? = nil) {
        DispatchQueue.main.async {
            TorStatusIndicator.shared.setStatus(.connected)
        }
    }
    
    @objc func didResignTorConnection(notification: Notification? = nil) {
        TorStatusIndicator.shared.setStatus(.disconnected)
    }
    
    @objc func didTurnOffTor(notification: Notification? = nil) {
        TorStatusIndicator.shared.setStatus(.turnedOff)
    }
    
    func registerAppforDetectLockState() {
        let callback: CFNotificationCallback = { center, observer, name, object, info in
            if TorClient.shared.isOperational {
                TorClient.shared.resign()
            }
        }

        CFNotificationCenterAddObserver(
            CFNotificationCenterGetDarwinNotifyCenter(),
            nil,
            callback,
            "com.apple.springboard.lockstate" as CFString,
            nil,
            .deliverImmediately
        )
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "VergeiOS")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func showPinUnlockViewController() {
        if !WalletManager.default.setup {
            return
        }

        if let rootVC = window?.visibleViewController() {
            if rootVC.isKind(of: PinUnlockViewController.self) {
                return
            }

            let vc = PinUnlockViewController.createFromStoryBoard()
            vc.fillPinFor = .wallet

            print("Show unlock view")
            rootVC.present(vc, animated: false, completion: nil)
        }
    }
    
}

