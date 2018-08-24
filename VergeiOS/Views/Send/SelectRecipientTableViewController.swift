//
//  SelectRecipientTableViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 11-08-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class SelectRecipientTableViewController: UITableViewController, UITextFieldDelegate {

    var delegate: RecipientDelegate!

    var addresses: [Address] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let xvgAddress1 = Address()
        xvgAddress1.name = "Marvin Piekarek"
        xvgAddress1.address = "DDd1pVWr8PPAw1z7DRwoUW6maWh5SsnCcp"
        
        let xvgAddress2 = Address()
        xvgAddress2.name = "Swen van Zanten"
        xvgAddress2.address = "DPEgHsW1Sox3m6ZiYVjiqVxak4NAThXXix"
        
        self.addresses.append(xvgAddress1)
        self.addresses.append(xvgAddress2)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Send to XVG address"
        }
        
        return "Or choose from the address book"
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        }
        
        // #warning Incomplete implementation, return the number of rows
        return self.addresses.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 && indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "addressCell", for: indexPath) as! AddressCell
            cell.addressTextField.text = delegate.selectedRecipientAddress()
            cell.addressTextField.delegate = self
            
            return cell
        }
        if indexPath.section == 0 && indexPath.row == 1 {
            return tableView.dequeueReusableCell(withIdentifier: "useAddressCell", for: indexPath)
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "addressBookCell", for: indexPath)

        cell.textLabel?.text = addresses[indexPath.row].name
        cell.detailTextLabel?.text = addresses[indexPath.row].address
        
        if addresses[indexPath.row].address == delegate.selectedRecipientAddress() {
            cell.accessoryType = .checkmark
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! AddressCell
            let address = cell.addressTextField.text
            
            if address?.count != 34 {
                tableView.deselectRow(at: indexPath, animated: true)
                return
            }

            delegate.didSelectRecipientAddress(address ?? "")
        } else {
            delegate.didSelectRecipientAddress(addresses[indexPath.row].address)
        }
        
        self.closeViewController(self)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.tableView(self.tableView, didSelectRowAt: IndexPath(row: 1, section: 0))
        
        return true
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 1:
            return 56
        default:
            return 44
        }
    }

    @IBAction func closeViewController(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
