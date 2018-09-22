//
//  MainTabBarController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 23-09-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

    let sendViewIndex: Int = 2
    
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
    
    func prepareSendView(transaction: SendTransaction) {
        // Select the send view.
        selectedIndex = sendViewIndex
        
        guard let navigationController = viewControllers?[sendViewIndex] as? UINavigationController else {
            return
        }
        
        guard let sendViewController = navigationController.viewControllers.first as? SendViewController else {
            return
        }
        
        // Set the transaction on the send view.
        DispatchQueue.main.async {
            sendViewController.didChangeSendTransaction(transaction)
        }
    }

}
