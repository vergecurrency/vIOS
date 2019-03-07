//
// Created by Swen van Zanten on 25/10/2018.
// Copyright (c) 2018 Verge Currency. All rights reserved.
//

import UIKit

extension UIAlertController {
    static func createDeleteContactAlert(handler: ((UIAlertAction) -> Void)?) -> UIAlertController{
        let alert = UIAlertController(
            title: "Remove contact",
            message: "Are you sure you want to remove the contact?",
            preferredStyle: .alert
        )

        let delete = UIAlertAction(title: "Delete", style: .destructive, handler: handler)

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(delete)

        return alert
    }
    
    static func createInvalidContactAlert() -> UIAlertController {
        let alert = UIAlertController(
            title: "Invalid contact data",
            message: "Please provide a valid name and XVG address",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
        
        return alert
    }

    static func createDeleteTransactionAlert(handler: ((UIAlertAction) -> Void)?) -> UIAlertController {
        let alert = UIAlertController(
            title: "Remove transaction",
            message: "Are you sure you want to remove this transaction?",
            preferredStyle: .alert
        )

        let delete = UIAlertAction(title: "Delete", style: .destructive, handler: handler)

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(delete)

        return alert
    }

    static func createAddressGapReachedAlert() -> UIAlertController {
        let alert = UIAlertController(
            title: "Cannot create address",
            message: "The maximum of inactive addresses have been reached. " +
                "Use one of the already generated addresses to create a new one.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Ok", style: .cancel))

        return alert
    }

    static func createSendMaxInfoAlert() -> UIAlertController {
        let alert = UIAlertController(
            title: "Failed fetching data",
            message: "Failed to fetch the send maximum info from the server, please try again.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Ok", style: .cancel))

        return alert
    }

    static func createStartTorActionSheet() -> UIAlertController {
        let actionSheet = UIAlertController(
            title: "Tor is not activated",
            message: "Do you want to send this transaction without Tor obfuscating your IP? " +
                "Or do you want to start Tor and hide your identity?",
            preferredStyle: .actionSheet
        )

        actionSheet.addAction(UIAlertAction(title: "Start Tor", style: .default))
        actionSheet.addAction(UIAlertAction(title: "Without Tor", style: .destructive))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        return actionSheet
    }
}
