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

    let addressBook: AddressBookManager = AddressBookManager()
    var contact: Address?
    var transactions: [Transaction] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        let styleCell = { (cell: TextCell) in
            cell.textLabel?.font = UIFont.avenir(size: 17)
            cell.textLabel?.textColor = UIColor.secondaryDark()
            cell.textField?.font = UIFont.avenir(size: 17).demiBold()
            cell.textField?.textColor = UIColor.secondaryDark()
        }

        tableView.backgroundColor = UIColor.backgroundGrey()

        form +++ Section("Contact Details")
            <<< TextRow("name") { row in
            row.title = "Name"
            row.placeholder = "Swen van Zanten"
            row.value = contact?.name ?? ""
            row.add(rule: RuleRequired())
        }.cellUpdate { cell, row in
            styleCell(cell)
        }
            <<< TextRow("address") { row in
            row.title = "Address"
            row.placeholder = "ErBhGNN9x8G513q3h5wdEgkoi2KbysUblJ8Jk7cjpG"
            row.value = contact?.address ?? ""
            row.add(rule: RuleRequired())
        }.cellUpdate { cell, row in
            styleCell(cell)
        }

        addTransactions()
    }

    func addTransactions() {
        guard let contact = contact else {
            return
        }

        let transactionsSection = Section("Transaction History")
        form +++ transactionsSection

        transactions = WalletManager.default.getTransactions(byAddress: contact.address)
        for transaction in transactions {
            transactionsSection
                <<< TransactionRow().cellSetup { cell, row in
                cell.setTransaction(transaction)
            }
        }
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.textColor = UIColor.secondaryDark()
        header.textLabel?.font = UIFont.avenir(size: 17).demiBold()
        header.textLabel?.frame = header.frame
        header.textLabel?.text = header.textLabel?.text?.capitalized
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)

        if indexPath.section == 1 {
            performSegue(withIdentifier: "TransactionTableViewController", sender: nil)
        }
    }

    override func insertAnimation(forRows rows: [BaseRow]) -> UITableView.RowAnimation {
        return .fade
    }

    override func insertAnimation(forSections sections: [Section]) -> UITableView.RowAnimation {
        return .fade
    }

    @IBAction func saveContact(_ sender: Any) {
        if form.validate().count == 0 {
            let address = Address()
            address.name = (form.rowBy(tag: "name") as! TextRow).value ?? ""
            address.address = (form.rowBy(tag: "address") as! TextRow).value ?? ""

            addressBook.put(address: address)

            self.contact = address

            if self.transactions.count == 0 {
                self.addTransactions()
            }
        }
    }

    @IBAction func deleteContact(_ sender: Any) {
        let alert = UIAlertController(
            title: "Remove contact",
            message: "Are you sure you want to remove the contact?",
            preferredStyle: .alert
        )

        let delete = UIAlertAction(title: "Delete", style: .destructive) { action in
            guard let contact = self.contact else {
                return
            }

            self.addressBook.remove(address: contact)

            self.navigationController?.popViewController(animated: true)
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(delete)

        present(alert, animated: true)
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "TransactionTableViewController" {
            if let vc = segue.destination as? TransactionTableViewController {
                vc.navigationItem.leftBarButtonItem = nil
                vc.transaction = transactions[tableView.indexPathForSelectedRow!.row]
            }
        }
    }
}
