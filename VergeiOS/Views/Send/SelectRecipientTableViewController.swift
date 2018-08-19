//
//  SelectRecipientTableViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 11-08-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class SelectRecipientTableViewController: UITableViewController, UITextFieldDelegate {

    var sendViewController: SendViewController?
    
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Send to XVG address"
        } else if section == 1 {
            return "or get address using BANS"
        }
        
        return "Or choose from the address book"
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        } else if section == 1 {
            return 2
        }
        
        // #warning Incomplete implementation, return the number of rows
        return self.addresses.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 && indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "addressCell", for: indexPath) as! AddressCell
            cell.addressTextField.text = self.sendViewController?.receipientTextField.valueLabel?.text
            cell.addressTextField.delegate = self
            
            return cell
        }
        if indexPath.section == 0 && indexPath.row == 1 {
            return tableView.dequeueReusableCell(withIdentifier: "useAddressCell", for: indexPath)
        }
        
        if indexPath.section == 1 && indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "bansAddressCell", for: indexPath) as! AddressCell
            cell.addressTextField.delegate = self
            
            return cell
        }
        if indexPath.section == 1 && indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "useAddressCell", for: indexPath)
            cell.textLabel?.text = "Search address"
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "addressBookCell", for: indexPath)

        cell.textLabel?.text = addresses[indexPath.row].name
        cell.detailTextLabel?.text = addresses[indexPath.row].address
        
        if addresses[indexPath.row].address == self.sendViewController?.receipientTextField.valueLabel?.text {
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
            
            self.sendViewController?.receipientTextField.valueLabel?.text = address
            self.closeViewController(self)
        } else if indexPath.section == 1 {
            let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as! AddressCell
            
            let bansDomainName = cell.addressTextField.text
            CloudflareAPIClient.shared.walletAddressFor(currency: "xvg", domainName: bansDomainName!) { resultAddress in
                
                if resultAddress?.count != 34 {
                    DispatchQueue.main.async {
                        tableView.deselectRow(at: indexPath, animated: true)
                        
                        let alert = UIAlertController(title: "XVG address missing", message: "There are not domain related XVG addresses found", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                    return
                }
                
                DispatchQueue.main.async {
                    tableView.deselectRow(at: indexPath, animated: true)
                    
                    let alert = UIAlertController(title: resultAddress, message: "related XVG address has been found", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Use it", style: .default, handler: { _ in
                        self.sendViewController?.receipientTextField.valueLabel?.text = resultAddress
                        self.closeViewController(self)
                    }))
                    alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        } else {
            self.sendViewController?.receipientTextField.valueLabel?.text = addresses[indexPath.row].address
            self.closeViewController(self)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.tableView(self.tableView, didSelectRowAt: IndexPath(row: 1, section: 0))
        
        return true
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func closeViewController(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
