//
//  TransactionTableViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 10-09-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class TransactionTableViewController: ThemeableViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var dateTimeLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet var addAddressButton: UIButton!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet var deleteTransactionBarButtonItem: UIBarButtonItem!
    @IBOutlet var repeatTransactionBarButtonItem: UIBarButtonItem!

    @IBOutlet weak var tableView: PlaceholderTableView!

    var applicationRepository: ApplicationRepository!
    var ratesClient: RatesClient!
    var transactionManager: TransactionManager!
    var addressBookManager: AddressBookRepository!
    var scrollViewEdger: ScrollViewEdger!

    var transaction: Vws.TxHistory?
    var items: [Vws.TxHistory] = []
    private var themedRepeatButtonItem: UIBarButtonItem?
    private var themedDeleteButtonItem: UIBarButtonItem?

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollViewEdger = ScrollViewEdger(scrollView: tableView)
        scrollViewEdger.hideBottomShadow = true
        setupNavigationButtons()

        DispatchQueue.main.async {
            self.scrollViewEdger.createShadowViews()
            // Select the current transaction.
            self.selectCurrentTransaction()
            self.tableView.setContentOffset(.zero, animated: true)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let transaction = transaction {
            setTransaction(transaction)
            loadTransactions(transaction)
        }
    }

    func setTransaction(_ transaction: Vws.TxHistory) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        dateTimeLabel.text = dateFormatter.string(from: transaction.timeReceived)

        if transaction.category == .Sent {
            if let resolvedRecipientName = transaction.resolvedRecipientName {
                nameLabel.text = resolvedRecipientName
                addAddressButton.isHidden = true
            } else if let name = addressBookManager.name(byAddress: transaction.address) {
                nameLabel.text = name
                addAddressButton.isHidden = true
            } else {
                nameLabel.text = transaction.address.truncated(limit: 6, position: .tail, leader: "******")
                addAddressButton.isHidden = false
            }
        } else {
            nameLabel.text = transaction.address.truncated(limit: 6, position: .tail, leader: "******")
            addAddressButton.isHidden = true
        }

        var prefix = ""
        if transaction.category == .Sent {
            amountLabel.textColor = ThemeManager.shared.vergeRed()
            iconImageView.image = UIImage(named: "Payment")

            prefix = "-"
        } else {
            navigationItem.rightBarButtonItems?.removeAll { item in
                return item == repeatTransactionBarButtonItem
            }
            amountLabel.textColor = ThemeManager.shared.vergeGreen()
            iconImageView.image = UIImage(named: "Receive")

            prefix = "+"
        }

        var rightItems = [UIBarButtonItem]()
        if transaction.category == .Sent, let repeatButton = themedRepeatButtonItem {
            rightItems.append(repeatButton)
        }

        if !transaction.confirmed {
            if let deleteButton = themedDeleteButtonItem {
                rightItems.append(deleteButton)
            }
        }
        navigationItem.rightBarButtonItems = rightItems

        amountLabel.text = "\(prefix) \(transaction.amountValue.toXvgCurrency())"
    }

    private func setupNavigationButtons() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            customView: makeNavigationButton(
                systemName: "xmark",
                accessibilityLabel: "Close",
                action: #selector(closeViewController(_:))
            )
        )
        themedRepeatButtonItem = UIBarButtonItem(
            customView: makeNavigationButton(
                systemName: "arrow.clockwise",
                accessibilityLabel: "Repeat transaction",
                action: #selector(repeatTransactionPushed(_:))
            )
        )
        themedDeleteButtonItem = UIBarButtonItem(
            customView: makeNavigationButton(
                systemName: "trash",
                accessibilityLabel: "Delete transaction",
                action: #selector(deleteTransactionPushed(_:))
            )
        )
    }

    private func makeNavigationButton(systemName: String, accessibilityLabel: String, action: Selector) -> UIButton {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.accessibilityLabel = accessibilityLabel
        button.tintColor = .white
        button.addTarget(self, action: action, for: .touchUpInside)

        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 34),
            button.heightAnchor.constraint(equalToConstant: 34)
        ])

        let iconView = UIImageView(image: UIImage(systemName: systemName)?.withRenderingMode(.alwaysTemplate))
        iconView.tintColor = .white
        iconView.contentMode = .scaleAspectFit
        iconView.isUserInteractionEnabled = false
        iconView.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(iconView)

        NSLayoutConstraint.activate([
            iconView.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 17),
            iconView.heightAnchor.constraint(equalToConstant: 17)
        ])

        applyRoundRetrowaveStyle(to: button)
        DispatchQueue.main.async { [weak self, weak button] in
            guard let button = button else {
                return
            }

            self?.applyRoundRetrowaveStyle(to: button)
            button.bringSubviewToFront(iconView)
        }

        return button
    }

    private func applyRoundRetrowaveStyle(to button: UIButton) {
        let gradientName = "RetrowaveTransactionDetailButtonGradient"
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

        button.layer.sublayers?
            .filter { $0.name == gradientName }
            .forEach { $0.removeFromSuperlayer() }

        guard button.bounds.width > 0 && button.bounds.height > 0 else {
            return
        }

        let gradient = CAGradientLayer()
        gradient.name = gradientName
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
        button.layer.insertSublayer(gradient, at: 0)
        button.subviews.forEach { button.bringSubviewToFront($0) }
    }

    func loadTransactions(_ transaction: Vws.TxHistory) {
        items = self.transactionManager.all(byAddress: transaction.address)
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 && transaction != nil {
            switch transaction!.category {
            case .Sent:
                let baseRows = transaction!.resolvedRecipientName == nil ? 3 : 4
                return transaction!.memo != nil ? baseRows + 1 : baseRows
            case .Received:
                return 3
            case .Moved:
                return 2
            }
        }

        return items.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 58.0 : 78.0
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let titles = [
            "transactions.transaction.details".localized,
            "transactions.transaction.history".localized
        ]

        return titles[section]
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.textColor = ThemeManager.shared.secondaryDark()
        header.textLabel?.font = UIFont.avenir(size: 17).demiBold()
        header.textLabel?.frame = header.frame
        header.textLabel?.text = header.textLabel?.text?.capitalized
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            var cell = tableView.dequeueReusableCell(withIdentifier: "transactionDetailCell")!
            let indexRow: Int = indexPath.row + (transaction?.category == .Moved ? 1 : 0)
            let hasResolvedName = transaction?.resolvedRecipientName != nil
            let effectiveRow = hasResolvedName && indexRow > 0 ? indexRow - 1 : indexRow

            if hasResolvedName && indexRow == 0 {
                cell.imageView?.image = UIImage(named: "Website")
                cell.textLabel?.text = "Web3 Name"
                cell.detailTextLabel?.text = transaction?.resolvedRecipientName
                cell.accessoryType = .none
            } else {
            switch effectiveRow {
            case 0:
                cell.imageView?.image = UIImage(named: "Address")
                cell.textLabel?.text = hasResolvedName ? "Resolved XVG Address" : "defaults.address".localized
                cell.detailTextLabel?.text = transaction?.address
                cell.accessoryType = .detailButton
                self.addTapRecognizer(cell: cell, action: #selector(self.addressDoubleTapped(recognizer:)))
            case 1:
                cell.imageView?.image = UIImage(named: "Confirmations")
                cell.textLabel?.text = "transactions.transaction.confirmations".localized
                cell.detailTextLabel?.text = transaction?.confirmationsCount
                cell.accessoryType = .none
            case 2:
                cell.imageView?.image = UIImage(named: "Block")
                cell.textLabel?.text = "txid"
                cell.detailTextLabel?.text = transaction?.txid
                cell.accessoryType = .detailButton
                self.addTapRecognizer(cell: cell, action: #selector(self.blockDoubleTapped(recognizer:)))
            case 3:
                cell = tableView.dequeueReusableCell(withIdentifier: "transactionMemoCell")!
                cell.textLabel?.text = transaction?.memo
                cell.imageView?.image = UIImage(named: "Memo")
                cell.accessoryType = .none
            default:
                break
            }
            }

            cell.imageView?.tintColor = ThemeManager.shared.secondaryLight()
            cell.textLabel?.textColor = ThemeManager.shared.secondaryDark()
            cell.detailTextLabel?.textColor = ThemeManager.shared.secondaryLight()

            return cell
        }

        let cell = Bundle.main.loadNibNamed(
            "TransactionTableViewCell",
            owner: self,
            options: nil
        )?.first as! TransactionTableViewCell

        let item = items[indexPath.row]

        var recipient = Contact()
        recipient.address = item.address
        recipient.name = nameLabel.text ?? item.address

        cell.setTransaction(item)

        return cell
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollViewEdger.updateView()
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 0 {
            return nil
        }

        return indexPath
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            return
        }

        if items[indexPath.row].txid == transaction?.txid {
            return
        }

        transaction = items[indexPath.row]
        setTransaction(transaction!)
        tableView.reloadData()
        selectCurrentTransaction()
    }

    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        if indexPath.section == 0 && self.transaction != nil {
            if self.transaction!.category == .Moved && indexPath.row == 1 {
                return self.loadWebsite(url: "\(Constants.blockchainExlorer)tx/\(self.transaction!.txid)")
            }

            let row = self.transaction!.resolvedRecipientName == nil ? indexPath.row : indexPath.row - 1
            guard row >= 0 else {
                return
            }

            switch row {
            case 0:
                self.loadWebsite(url: "\(Constants.blockchainExlorer)address/\(self.transaction!.address)")
            case 2:
                self.loadWebsite(url: "\(Constants.blockchainExlorer)tx/\(self.transaction!.txid)")
            default: break
            }
        }
    }

    func selectCurrentTransaction() {
        for (index, item) in items.enumerated() where (item.txid == self.transaction?.txid) {
            let indexPath = IndexPath(row: index, section: 1)
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
        }
    }

    func repeatTransaction(_ transaction: Vws.TxHistory) {
        if self.navigationController?.popViewController(animated: true) == nil {
            self.closeViewController(self)
        }

        DispatchQueue.main.async {
            // Create a send transaction.
            let sendTransaction = WalletTransactionFactory(
                ratesClient: self.ratesClient,
                fiatCurrency: self.applicationRepository.currency
            )
            sendTransaction.address = transaction.address
            sendTransaction.amount = transaction.amountValue

            // Notify the system to show the send view.
            NotificationCenter.default.post(name: .demandSendView, object: sendTransaction)
        }
    }

    private func loadWebsite(url: String) {
        if let path: URL = URL(string: url) {
            UIApplication.shared.open(path, options: [:])
        }
    }

    func addTapRecognizer(cell: UITableViewCell, action: Selector) {
        let gesture = UITapGestureRecognizer(target: self, action: action)
        gesture.numberOfTapsRequired = 2

        cell.addGestureRecognizer(gesture)
    }

    @objc func addressDoubleTapped(recognizer: UIGestureRecognizer) {
        UIPasteboard.general.string = transaction!.address
        NotificationBar.shared.showMessage("addresses.addressCopied".localized, duration: 3)
    }

    @objc func blockDoubleTapped(recognizer: UITapGestureRecognizer) {
        UIPasteboard.general.string = transaction!.txid
        NotificationBar.shared.showMessage("transactions.transaction.txidCopied".localized, duration: 3)
    }

    @IBAction func deleteTransactionPushed(_ sender: Any) {
        guard let transaction = transaction else {
            return
        }

        let confirmation = UIAlertController.createDeleteTransactionAlert { _ in
            self.transactionManager.remove(transaction: transaction)

            NotificationCenter.default.post(name: .didReceiveTransaction, object: nil)

            self.dismiss(animated: true)
        }

        present(confirmation, animated: true)
    }

    @IBAction func repeatTransactionPushed(_ sender: Any) {
        if let transaction = transaction {
            repeatTransaction(transaction)
        }
    }

    @IBAction func closeViewController(_ sender: Any) {
        self.dismiss(animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ContactTableViewController {
            var contact = Contact()
            contact.address = transaction!.address
            vc.contact = contact
        }
    }
}
