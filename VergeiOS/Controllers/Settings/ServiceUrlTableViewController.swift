//
//  ServiceUrlTableViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 11/12/2018.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class ServiceUrlTableViewController: EdgedTableViewController {

    @IBOutlet weak var serviceUrlTextField: UITextField!

    var applicationRepository: ApplicationRepository!
    var walletClient: WalletClientProtocol!
    var walletManager: WalletManagerProtocol!

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
            title: "settings.serviceUrl.alert.title".localized,
            message: "settings.serviceUrl.alert.message".localized,
            preferredStyle: .alert
        )

        self.present(alert, animated: true)

        self.previousServiceUrl = self.applicationRepository.walletServiceUrl
        self.applicationRepository.walletServiceUrl = self.serviceUrlTextField.text!

        self.walletClient.resetServiceUrl(baseUrl: self.applicationRepository.walletServiceUrl)
        self.walletManager
            .getWallet()
            .then { _ in
                self.urlChanged(alert: alert)
            }.catch { error in
                self.errorDuringChange(alert: alert, error: error)
            }
    }

    func errorDuringChange(alert: UIAlertController, error: Error) {
        alert.addAction(UIAlertAction(title: "defaults.cancel".localized, style: .cancel))
        alert.addAction(UIAlertAction(title: "settings.serviceUrl.alert.usePrevUrl".localized, style: .default) { _ in
            self.rollbackServiceUrl(serviceUrl: self.previousServiceUrl)
        })
        alert.title = "settings.serviceUrl.alert.errorChanging".localized
        alert.message = "\("settings.serviceUrl.alert.errorChanging2".localized): \(error.localizedDescription)"
    }

    func urlChanged(alert: UIAlertController) {
        alert.addAction(UIAlertAction(title: "defaults.done".localized, style: .default))
        alert.title = "settings.serviceUrl.alert.title2".localized
        alert.message = "settings.serviceUrl.alert.message2".localized
    }

    func rollbackServiceUrl(serviceUrl: String) {
        self.applicationRepository.walletServiceUrl = serviceUrl
        self.serviceUrlTextField.text = serviceUrl
        self.walletClient.resetServiceUrl(baseUrl: serviceUrl)
        self.walletManager
            .getWallet()
            .catch { error in
                print(error)
            }
    }
}
