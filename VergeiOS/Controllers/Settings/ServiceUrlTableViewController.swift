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
    var walletTicker: WalletTicker!
    var walletClient: WalletClientProtocol!
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

        self.walletTicker.stop()
        self.walletClient.resetServiceUrl(baseUrl: self.applicationRepository.walletServiceUrl)

        self.joinWallet(alert: alert)
    }

    func errorDuringChange(alert: UIAlertController) {
        alert.addAction(UIAlertAction(title: "defaults.cancel".localized, style: .cancel))
        alert.addAction(UIAlertAction(title: "settings.serviceUrl.alert.usePrevUrl".localized, style: .default) { _ in
            self.rollbackServiceUrl(serviceUrl: self.previousServiceUrl)
        })
        alert.title = "settings.serviceUrl.alert.errorChanging".localized
        alert.message = "settings.serviceUrl.alert.errorChanging2".localized
    }

    func urlChanged(alert: UIAlertController) {
        alert.addAction(UIAlertAction(title: "defaults.done".localized, style: .default))
        alert.title = "settings.serviceUrl.alert.title2".localized
        alert.message = "settings.serviceUrl.alert.message2".localized
    }

    func rollbackServiceUrl(serviceUrl: String) {
        applicationRepository.walletServiceUrl = serviceUrl
        serviceUrlTextField.text = serviceUrl
        walletClient.resetServiceUrl(baseUrl: serviceUrl)
        walletTicker.start()
    }

    private func joinWallet(alert: UIAlertController, create: Bool = true) {
        self.walletClient.joinWallet(walletIdentifier: self.applicationRepository.walletId!) { error in
            guard let error = error else {
                return DispatchQueue.main.async {
                    self.walletTicker.start()
                    self.urlChanged(alert: alert)
                }
            }

            print(error)

            if !create {
                return
            }

            print("Joining wallet failed... trying to create a new wallet")

            return self.createWallet(alert: alert)
        }
    }

    private func createWallet(alert: UIAlertController) {
        self.walletClient.createWallet(
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

            self.joinWallet(alert: alert, create: false)
        }
    }
}
