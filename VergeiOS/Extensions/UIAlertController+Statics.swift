//
// Created by Swen van Zanten on 25/10/2018.
// Copyright (c) 2018 Verge Currency. All rights reserved.
//

import UIKit

extension UIAlertController {
    static func createDeleteContactAlert(handler: ((UIAlertAction) -> Void)?) -> UIAlertController{
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
        alert.addAction(UIAlertAction(title: "defaults.open".localized, style: .default) { action in
            if let path: URL = URL(string: Constants.termsOfUse) {
                UIApplication.shared.open(path, options: [:])
            }
        })

        return alert
    }
    
    static func restartAlert() -> UIAlertController {
        let alert = UIAlertController(title: "alerts.restart.title".localized, message: nil, preferredStyle: .alert)
        
        return alert
    }
}
