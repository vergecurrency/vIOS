//
//  ContactTableViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 21/10/2018.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit
import Eureka

class ContactTableViewController: FormViewController {

    var transactionManager: TransactionManager!
    var addressBookManager: AddressBookRepository!

    var contact: Contact?
    var transactions: [TxHistory] = []
    var trashButtonItem: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.trashButtonItem = UIBarButtonItem(
            barButtonSystemItem: .trash,
            target: self,
            action: #selector(deleteContact)
        )
        self.trashButtonItem.tintColor = ThemeManager.shared.vergeRed()

        if contact != nil && contact!.name != "" {
            navigationItem.rightBarButtonItems?.append(self.trashButtonItem)
        }

        let styleCell = { (cell: TextCell) in
            cell.textLabel?.font = UIFont.avenir(size: 17)
            cell.textLabel?.textColor = ThemeManager.shared.secondaryDark()
            cell.textField?.font = UIFont.avenir(size: 17).demiBold()
            cell.textField?.textColor = ThemeManager.shared.secondaryDark()
            cell.backgroundColor = ThemeManager.shared.backgroundWhite()
            cell.textLabel?.updateColors()
            cell.textField?.updateColors()
        }

        self.tableView.backgroundColor = ThemeManager.shared.backgroundGrey()
        self.tableView.separatorColor = ThemeManager.shared.separatorColor()

        self.form +++ Section("transactions.contact.section.details".localized)
            <<< TextRow("name") { row in
            row.title = "transactions.contact.name".localized
            row.placeholder = "Swen van Zanten"
            row.value = contact?.name ?? ""
            row.add(rule: RuleRequired())
        }.cellUpdate { cell, _ in
            styleCell(cell)
        }
            <<< TextRow("address") { row in
            row.title = "defaults.address".localized
            row.placeholder = "ErBhGNN9x8G513q3h5wdEgkoi2KbysUblJ8Jk7cjpG"
            row.value = contact?.address ?? ""
            row.add(rule: RuleRequired())
        }.cellUpdate { cell, _ in
            styleCell(cell)
        }

        self.addTransactions()
    }

    func addTransactions() {
        guard let contact = self.contact else {
            return
        }

        self.transactions = self.transactionManager.all(byAddress: contact.address)

        if self.transactions.count == 0 {
            return
        }

        let transactionsSection = Section("transactions.contact.section.history".localized)
        self.form +++ transactionsSection

        for transaction in self.transactions {
            transactionsSection
                <<< TransactionRow().cellSetup { cell, _ in
                cell.setTransaction(transaction)
            }
        }
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.textColor = ThemeManager.shared.secondaryDark()
        header.textLabel?.font = UIFont.avenir(size: 17).demiBold()
        header.textLabel?.frame = header.frame
        header.textLabel?.text = header.textLabel?.text?.capitalized
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)

        if indexPath.section == 1 {
            self.performSegue(withIdentifier: "TransactionTableViewController", sender: nil)
        }
    }

    override func insertAnimation(forRows rows: [BaseRow]) -> UITableView.RowAnimation {
        return .fade
    }

    override func insertAnimation(forSections sections: [Section]) -> UITableView.RowAnimation {
        return .fade
    }

    @IBAction func saveContact(_ sender: Any) {
        var tempContact = Contact()
        tempContact.name = (self.form.rowBy(tag: "name") as! TextRow).value ?? ""
        tempContact.address = (self.form.rowBy(tag: "address") as! TextRow).value ?? ""

        if (!tempContact.isValid()) {
            let alert = UIAlertController.createInvalidContactAlert()
            self.present(alert, animated: true)

            return
        }

        self.addressBookManager.put(address: tempContact)

        self.contact = tempContact

        if self.transactions.count == 0 {
            self.addTransactions()
        }

        NotificationManager.shared.showMessage("transactions.contact.saved".localized, duration: 1)

        // Pop screen on completion
        self.navigationController?.popViewController(animated: true)
    }

    @objc func deleteContact(_ sender: Any) {
        let alert = UIAlertController.createDeleteContactAlert { _ in
            guard let contact = self.contact else {
                return
            }

            self.addressBookManager.remove(address: contact)

            self.navigationController?.popViewController(animated: true)
        }

        self.present(alert, animated: true)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "TransactionTableViewController" {
            if let vc = segue.destination as? TransactionTableViewController {
                vc.navigationItem.leftBarButtonItem = nil
                vc.transaction = self.transactions[self.tableView.indexPathForSelectedRow!.row]
            }
        }
    }
}
