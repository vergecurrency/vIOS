//
//
//  NfcTableViewController.swift
//  VergeiOS
//
//  Created by MaXius on 25/08/2020.
//  Copyright © 2020 Verge Currency. All rights reserved.
//

import UIKit
import CoreNFC

class NfcTableViewController: EdgedTableViewController {

    @IBOutlet weak var headerImage: UIImageView!
    @IBOutlet weak var useNfcSwitch: UISwitch!

    var applicationRepository: ApplicationRepository!
    var nfcNotSupported = true

    override func viewDidLoad() {
        super.viewDidLoad()

        if (NFCNDEFReaderSession.readingAvailable) {
            self.nfcNotSupported = false
        }

        if (self.nfcNotSupported) {
            self.useNfcSwitch.setOn(false, animated: false)
            self.useNfcSwitch.isEnabled = false
        } else {
            self.useNfcSwitch.setOn(self.applicationRepository.useNfc, animated: false)
        }
    }

    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if (self.nfcNotSupported) {
            guard let footer = view as? UITableViewHeaderFooterView else { return }
            footer.textLabel?.text = "settings.br.footer.unsupported".localized
        }
    }

    @IBAction func switchForUsingNFC(_ sender: UISwitch) {
        self.applicationRepository.useNfc = sender.isOn
    }

}
