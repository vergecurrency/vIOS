//
//  SelectRecipientTableViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 11-08-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class SelectRecipientTableViewController: AbstractContactsTableViewController {

    weak var sendTransactionDelegate: SendTransactionDelegate!
    var sendTransaction: WalletTransactionFactory?
    private var navigationActionButtons: [UIButton] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        sendTransaction = sendTransactionDelegate.getSendTransaction()
        configureNavigationActions()

        loadContacts()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        navigationActionButtons.forEach { applyRoundRetrowaveStyle(to: $0) }
    }

    private func configureNavigationActions() {
        let closeButton = makeNavigationActionButton(
            label: "x",
            accessibilityLabel: "Close",
            action: #selector(closeViewController(_:))
        )
        let addButton = makeNavigationActionButton(
            label: "+",
            accessibilityLabel: "Add Contact",
            action: #selector(addContact)
        )
        let editButton = makeNavigationActionButton(
            label: "Edit",
            accessibilityLabel: "Edit Contacts",
            action: #selector(toggleEditing)
        )

        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: closeButton)
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(customView: addButton),
            UIBarButtonItem(customView: editButton)
        ]
        navigationActionButtons = [closeButton, addButton, editButton]
    }

    private func makeNavigationActionButton(
        label: String,
        accessibilityLabel: String,
        action: Selector
    ) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(nil, for: .normal)
        button.setTitle(nil, for: .normal)
        button.tintColor = .white
        button.accessibilityLabel = accessibilityLabel
        button.addTarget(self, action: action, for: .touchUpInside)

        let titleLabel = UILabel()
        titleLabel.text = label
        titleLabel.textColor = .white
        titleLabel.font = label == "+" ? UIFont.systemFont(ofSize: 25, weight: .semibold) : UIFont.avenir(size: 12).demiBold()
        titleLabel.textAlignment = .center
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.65
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.isUserInteractionEnabled = false
        button.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 34),
            button.heightAnchor.constraint(equalToConstant: 34),
            titleLabel.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: button.leadingAnchor, constant: 4),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: button.trailingAnchor, constant: -4)
        ])
        applyRoundRetrowaveStyle(to: button)

        return button
    }

    private func applyRoundRetrowaveStyle(to button: UIButton) {
        let gradientName = "RetrowaveRoundNavigationButtonGradient"
        button.backgroundColor = UIColor(rgb: 0x12071A)
        button.tintColor = .white
        button.layer.cornerRadius = 17
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(rgb: 0xFF3DF2).withAlphaComponent(0.75).cgColor
        button.layer.shadowColor = ThemeManager.shared.primaryLight().cgColor
        button.layer.shadowOpacity = 0.38
        button.layer.shadowRadius = 10
        button.layer.shadowOffset = .zero
        button.clipsToBounds = false

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

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)

        let address = contact(byIndexpath: indexPath)

        if address.address == sendTransaction?.address {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        guard editingStyle == .delete else {
            return
        }

        addressBookManager.remove(address: contact(byIndexpath: indexPath))
        loadContacts(searchController.searchBar.text ?? "")
        setupView()
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sendTransaction?.address = contact(byIndexpath: indexPath).address
        sendTransactionDelegate.didChangeSendTransaction(sendTransaction!)

        searchController.isActive = false
        closeViewController(self)
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }

    @IBAction func closeViewController(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @objc private func toggleEditing() {
        setEditing(!isEditing, animated: true)
    }

    @objc private func addContact() {
        let alert = UIAlertController(
            title: "Add Contact",
            message: "Save an XVG address or Web3 name to your contact book.",
            preferredStyle: .alert
        )
        alert.addTextField { textField in
            textField.placeholder = "Name"
            textField.autocapitalizationType = .words
        }
        alert.addTextField { textField in
            textField.placeholder = "XVG address or Web3 name"
            textField.autocapitalizationType = .none
            textField.autocorrectionType = .no
            textField.spellCheckingType = .no
        }

        alert.addAction(UIAlertAction(title: "defaults.cancel".localized, style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default) { _ in
            let name = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let recipient = alert.textFields?.last?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            self.saveManualContact(name: name, recipient: recipient)
        })
        alert.applyRetrowaveTheme()
        present(alert, animated: true)
    }

    private func saveManualContact(name: String, recipient: String) {
        guard !name.isEmpty, !recipient.isEmpty else {
            return present(UIAlertController.createInvalidContactAlert(), animated: true)
        }

        AddressValidator().validateOrResolve(string: recipient) { valid, address, _, _, _, error in
            DispatchQueue.main.async {
                guard valid, let address = address else {
                    return self.showInvalidContactRecipient(error: error)
                }

                if AddressValidator.looksLikeResolvableName(recipient) {
                    ResolvedRecipientRepository.save(name: recipient, for: address)
                }

                var contact = Contact()
                contact.name = name
                contact.address = address

                guard contact.isValid() else {
                    return self.present(UIAlertController.createInvalidContactAlert(), animated: true)
                }

                self.addressBookManager.put(address: contact)
                self.loadContacts()
                self.setupView()
                self.tableView.reloadData()
                NotificationBar.shared.showMessage("Contact saved", duration: 1)
            }
        }
    }

    private func showInvalidContactRecipient(error: AddressValidator.ResolutionError?) {
        let message: String
        switch error {
        case .missingApiToken:
            message = "Unstoppable Domains API token is not configured."
        case .httpStatus(let status):
            message = "Unstoppable Domains lookup failed with HTTP \(status)."
        case .emptyResponse:
            message = "Unstoppable Domains returned an empty response."
        case .noRecords:
            message = "That Web3 name has no crypto records."
        case .recordNotFound:
            message = "That Web3 name does not have a crypto.XVG.address record."
        case .invalidJson:
            message = "Unstoppable Domains returned a response this app could not read."
        case .invalidResolvedAddress:
            message = "That Web3 name resolved, but not to a valid Verge address."
        case .none:
            message = "Enter a valid XVG address or Web3 name."
        }

        let alert = UIAlertController(
            title: "Invalid Contact",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "defaults.ok".localized, style: .cancel))
        alert.applyRetrowaveTheme()
        present(alert, animated: true)
    }
}
