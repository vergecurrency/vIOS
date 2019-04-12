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

    var applicationRepository: ApplicationRepository!
    var walletTicker: WalletTicker!
    var walletClient: WalletClient!
    var previousServiceUrl: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        previousServiceUrl = applicationRepository.walletServiceUrl
        serviceUrlTextField.text = applicationRepository.walletServiceUrl
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

        previousServiceUrl = applicationRepository.walletServiceUrl
        applicationRepository.walletServiceUrl = serviceUrlTextField.text!

        walletTicker.stop()
        walletClient.resetServiceUrl(baseUrl: applicationRepository.walletServiceUrl)

        walletClient.createWallet(
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

            self.walletClient.joinWallet(walletIdentifier: self.applicationRepository.walletId!) { error in
                print(error ?? "")

                DispatchQueue.main.async {
                    self.walletTicker.start()
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
        applicationRepository.walletServiceUrl = serviceUrl
        serviceUrlTextField.text = serviceUrl
        walletClient.resetServiceUrl(baseUrl: serviceUrl)
        walletTicker.start()
    }
}
