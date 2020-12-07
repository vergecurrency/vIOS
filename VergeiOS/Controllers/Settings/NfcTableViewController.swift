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
            nfcNotSupported = false
        }

        if (nfcNotSupported) {
            useNfcSwitch.setOn(false, animated: false)
            useNfcSwitch.isEnabled = false
        } else {
            useNfcSwitch.setOn(applicationRepository.useNfc, animated: false)
        }
    }

    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if (nfcNotSupported) {
            guard let footer = view as? UITableViewHeaderFooterView else { return }
            footer.textLabel?.text = "settings.br.footer.unsupported".localized
        }
    }

    @IBAction func switchForUsingNFC(_ sender: UISwitch) {
        applicationRepository.useNfc = sender.isOn
    }

}
