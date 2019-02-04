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

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(demandSendView(notification:)),
            name: .demandSendView,
            object: nil
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            if let sendTransaction = delegate.sendRequest {
                // Prepare the send view with the transaction.
                prepareSendView(transaction: sendTransaction)
                
                // Remove the transaction from the delegate.
                delegate.sendRequest = nil
            }
        }
    }
    
    func prepareSendView(transaction: TransactionFactory) {
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
        if let sendTransaction = notification.object as? TransactionFactory {
            prepareSendView(transaction: sendTransaction)
        }
    }

}
