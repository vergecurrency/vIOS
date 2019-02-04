//
//  ServiceUrlTableViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 11/12/2018.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class ServiceUrlTableViewController: UITableViewController {

    @IBOutlet weak var serviceUrlTextField: UITextField!

    var previousServiceUrl: String = ApplicationRepository.default.walletServiceUrl

    override func viewDidLoad() {
        super.viewDidLoad()

        serviceUrlTextField.text = ApplicationRepository.default.walletServiceUrl
    }

    @IBAction func setDefaultServiceUrl(_ sender: Any) {
        serviceUrlTextField.text = Constants.bwsEndpoint
    }

    @IBAction func saveServiceUrl(_ sender: Any) {
        let alert = UIAlertController(
            title: "Changing Service",
            message: "Changing the service URL, please wait a moment...",
            preferredStyle: .alert
        )

        present(alert, animated: true)

        previousServiceUrl = ApplicationRepository.default.walletServiceUrl
        ApplicationRepository.default.walletServiceUrl = serviceUrlTextField.text!

        WalletTicker.shared.stop()
        WalletClient.shared.resetServiceUrl(baseUrl: ApplicationRepository.default.walletServiceUrl)

        WalletClient.shared.createWallet(
            walletName: "ioswallet",
            copayerName: "iosuser",
            m: 1,
            n: 1,
            options: nil
        ) { error, secret in
            if (error != nil || secret == nil) {
                DispatchQueue.main.async {
                    self.errorDuringChange(alert: alert)
                }

                print(error ?? "")
                return
            }

            WalletClient.shared.joinWallet(walletIdentifier: ApplicationRepository.default.walletId!) { error in
                print(error ?? "")

                DispatchQueue.main.async {
                    WalletTicker.shared.start()

                    self.urlChanged(alert: alert)
                }
            }
        }
    }

    func errorDuringChange(alert: UIAlertController) {
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Use previous service URL", style: .default) { action in
            self.rollbackServiceUrl(serviceUrl: self.previousServiceUrl)
        })
        alert.title = "Error Changing"
        alert.message = "An error was raised during the service URL change. Please try again or use another service URL."
    }

    func urlChanged(alert: UIAlertController) {
        alert.addAction(UIAlertAction(title: "Done", style: .default))
        alert.title = "Changed Service"
        alert.message = "Successfully changed the service URL."
    }

    func rollbackServiceUrl(serviceUrl: String) {
        ApplicationRepository.default.walletServiceUrl = serviceUrl
        serviceUrlTextField.text = serviceUrl
        WalletClient.shared.resetServiceUrl(baseUrl: serviceUrl)
        WalletTicker.shared.start()
    }
}
