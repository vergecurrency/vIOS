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
    private var didStyleFooterButtons = false

    override func viewDidLoad() {
        super.viewDidLoad()

        previousServiceUrl = applicationRepository.walletServiceUrl
        serviceUrlTextField.text = applicationRepository.walletServiceUrl
        styleServiceUrlScreen()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if didStyleFooterButtons {
            updateFooterButtonGradients()
        } else {
            styleFooterButtons()
        }
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
        alert.applyRetrowaveTheme()

        self.present(alert, animated: true)

        self.previousServiceUrl = self.applicationRepository.walletServiceUrl
        // ⚠️ Avoid force-unwrapping; use nil-coalescing
        self.applicationRepository.walletServiceUrl = self.serviceUrlTextField.text ?? ""

        self.walletClient.resetServiceUrl(baseUrl: self.applicationRepository.walletServiceUrl)

        // Launch async task
        Task {
            do {
                _ = try await self.walletManager.getWallet()
                await MainActor.run {
                    self.urlChanged(alert: alert)
                }
            } catch {
                await MainActor.run {
                    self.errorDuringChange(alert: alert, error: error)
                }
            }
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

//    func rollbackServiceUrl(serviceUrl: String) {
//        self.applicationRepository.walletServiceUrl = serviceUrl
//        self.serviceUrlTextField.text = serviceUrl
//        self.walletClient.resetServiceUrl(baseUrl: serviceUrl)
//        self.walletManager
//            .getWallet()
//            .catch { error in
//                print(error)
//            }
//    }
    func rollbackServiceUrl(serviceUrl: String) {
        self.applicationRepository.walletServiceUrl = serviceUrl
        self.serviceUrlTextField.text = serviceUrl
        self.walletClient.resetServiceUrl(baseUrl: serviceUrl)

        Task {
            do {
                _ = try await self.walletManager.getWallet()
                // Optionally: handle success (e.g., refresh UI)
            } catch {
                print("Error during rollback getWallet: \(error)")
                // Optionally: show error to user, log, etc.
            }
        }
    }

    private func styleServiceUrlScreen() {
        view.backgroundColor = ThemeManager.shared.backgroundGrey()
        tableView.backgroundColor = ThemeManager.shared.backgroundGrey()
        tableView.separatorColor = ThemeManager.shared.separatorColor()
        tableView.indicatorStyle = .white

        serviceUrlTextField.textColor = .white
        serviceUrlTextField.tintColor = ThemeManager.shared.primaryLight()
        serviceUrlTextField.backgroundColor = UIColor(rgb: 0x12061F).withAlphaComponent(0.94)
        serviceUrlTextField.layer.cornerRadius = 8
        serviceUrlTextField.layer.borderWidth = 1
        serviceUrlTextField.layer.borderColor = ThemeManager.shared.primaryLight().withAlphaComponent(0.48).cgColor
        serviceUrlTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 1))
        serviceUrlTextField.leftViewMode = .always
        serviceUrlTextField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 1))
        serviceUrlTextField.rightViewMode = .always
        serviceUrlTextField.attributedPlaceholder = NSAttributedString(
            string: serviceUrlTextField.placeholder ?? "",
            attributes: [.foregroundColor: ThemeManager.shared.secondaryLight().withAlphaComponent(0.72)]
        )
    }

    private func styleFooterButtons() {
        guard let footerView = tableView.tableFooterView else {
            return
        }

        footerView.backgroundColor = ThemeManager.shared.backgroundGrey()
        footerView.subviews
            .compactMap { $0 as? UIButton }
            .forEach { button in
                styleFooterButton(button)
            }

        didStyleFooterButtons = true
        footerView.subviews
            .compactMap { $0 as? UIButton }
            .forEach { button in
                let minimumWidth: CGFloat = button.currentTitle == "settings.serviceUrl.defaultUrlButton".localized ? 220 : 295
                let width = button.widthAnchor.constraint(greaterThanOrEqualToConstant: minimumWidth)
                width.priority = .defaultHigh
                width.isActive = true
            }
    }

    private func styleFooterButton(_ button: UIButton) {
        button.titleLabel?.numberOfLines = 1
        button.titleLabel?.lineBreakMode = .byClipping
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.78
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
        button.titleEdgeInsets = .zero
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(UIColor.white.withAlphaComponent(0.78), for: .highlighted)
        button.tintColor = .white
        button.backgroundColor = UIColor(rgb: 0x12071A)
        button.layer.cornerRadius = min(18, max(8, button.bounds.height / 2))
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(rgb: 0xFF3DF2).withAlphaComponent(0.72).cgColor
        button.layer.shadowColor = UIColor(rgb: 0xFF3DF2).cgColor
        button.layer.shadowOpacity = 0.32
        button.layer.shadowRadius = 12
        button.layer.shadowOffset = .zero
        button.clipsToBounds = false
        addRetrowaveGradient(to: button)
    }

    private func addRetrowaveGradient(to button: UIButton) {
        let gradientName = "RetrowaveServiceUrlButtonGradient"
        guard button.bounds.width > 0 && button.bounds.height > 0 else {
            return
        }

        let gradient: CAGradientLayer
        if let existingGradient = button.layer.sublayers?
            .first(where: { $0.name == gradientName }) as? CAGradientLayer {
            gradient = existingGradient
        } else {
            gradient = CAGradientLayer()
            gradient.name = gradientName
            button.layer.insertSublayer(gradient, at: 0)
        }

        gradient.frame = button.bounds
        gradient.cornerRadius = button.layer.cornerRadius
        gradient.colors = [
            UIColor(rgb: 0x14071F).cgColor,
            UIColor(rgb: 0x3A125C).cgColor,
            UIColor(rgb: 0x12071A).cgColor
        ]
        gradient.locations = [0.0, 0.52, 1.0]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        button.subviews.forEach { button.bringSubviewToFront($0) }
    }

    private func updateFooterButtonGradients() {
        tableView.tableFooterView?.subviews
            .compactMap { $0 as? UIButton }
            .forEach { button in
                button.layer.sublayers?
                    .compactMap { $0 as? CAGradientLayer }
                    .filter { $0.name == "RetrowaveServiceUrlButtonGradient" }
                    .forEach {
                        $0.frame = button.bounds
                        $0.cornerRadius = button.layer.cornerRadius
                    }
            }
    }
}
