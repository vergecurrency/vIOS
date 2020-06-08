//
// Created by Swen van Zanten on 25/10/2018.
// Copyright (c) 2018 Verge Currency. All rights reserved.
//

import UIKit

extension UIAlertController {
    static func createWalletSetupErrorAlert(
        error: String,
        handler: @escaping (UIAlertAction) -> Void
    ) -> UIAlertController {
        let alert = UIAlertController(
            title: "alert.walletSetup.title".localized,
            message: "\("alert.walletSetup.message".localized): \(error)",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "defaults.ok".localized, style: .cancel))
        alert.addAction(UIAlertAction(title: "defaults.support", style: .default, handler: handler))

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
