//
//  Created by Swen van Zanten on 29-07-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit
import Logging

class ConfirmPaperkeyViewController: AbstractPaperkeyViewController, UITextFieldDelegate {

    @IBOutlet weak var firstWordLabel: UILabel!
    @IBOutlet weak var secondWordLabel: UILabel!

    @IBOutlet weak var firstWordTextfield: UITextField!
    @IBOutlet weak var secondWordTextfield: UITextField!

    var applicationRepository: ApplicationRepository!
    var log: Logger!

    var mnemonic: [String] = []
    var randomNumbers: [Int] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.log.debug("confirm paper key view loaded with mnemonic: \(mnemonic)")

        self.randomNumbers = self.selectRandomNumbers()

        self.firstWordLabel.text = "paperKey.word".localized + " #\(randomNumbers.first!)"
        self.secondWordLabel.text = "paperKey.word".localized + " #\(randomNumbers.last!)"

        self.firstWordTextfield.delegate = self
        self.secondWordTextfield.delegate = self
    }

    func selectRandomNumbers() -> [Int] {
        var numbers: [Int] = []

        for _ in 1...2 {
            var number = Int(arc4random_uniform(11) + 1)
            while numbers.contains(number) {
                number = Int(arc4random_uniform(11) + 1)
            }

            numbers.append(number)
        }

        return numbers.sorted()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.firstWordTextfield {
            self.secondWordTextfield.becomeFirstResponder()

            return true
        }

        textField.resignFirstResponder()

        return true
    }

    @IBAction func submitPaperkeyConfirmation(_ sender: Any) {
        self.firstWordTextfield.backgroundColor = .white

        // Add shake effect...
        if self.firstWordTextfield.text != self.mnemonic[self.randomNumbers.first! - 1] {
            self.firstWordTextfield.backgroundColor = ThemeManager.shared.vergeRed().withAlphaComponent(0.15)
            return
        }

        if self.secondWordTextfield.text != self.mnemonic[self.randomNumbers.last! - 1] {
            self.secondWordTextfield.backgroundColor = ThemeManager.shared.vergeRed().withAlphaComponent(0.15)
            return
        }

        // Save the mnemonic.
        self.applicationRepository.mnemonic = mnemonic

        // Finish the welcome guide.
        self.performSegue(withIdentifier: "finishWelcomeGuide", sender: self)
    }

}
