//
//  PaperKeyWordsViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 29-07-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit
import BitcoinKit

class PaperKeyWordsViewController: AbstractPaperkeyViewController {
    
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var progressionLabel: UILabel!
    @IBOutlet weak var previousButton: RoundedButton!
    @IBOutlet weak var nextButton: RoundedButton!
    
    var mnemonic: [String] = []
    var selectedWord = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Generate a new mnemonic.
        do {
            let newMnemonic = try Mnemonic.generate()
            mnemonic = ApplicationRepository.default.mnemonic ?? newMnemonic
        } catch {
            // TODO: handle the error.
            print(error.localizedDescription)
            navigationController?.popViewController(animated: true)
        }

        if navigationController?.viewControllers.first?.isKind(of: PaperKeyWordsViewController.self) ?? false {
            let closeButton = UIBarButtonItem(
                image: UIImage(named: "Close"),
                style: .plain,
                target: self,
                action: #selector(dismissView)
            )

            navigationItem.setLeftBarButton(closeButton, animated: false)
        }

        self.wordLabel.text = self.mnemonic.first
        
        self.updateView()
    }
    
    @IBAction func previousWord(_ sender: Any) {
        self.selectedWord -= 1
        self.wordLabel.text = self.mnemonic[self.selectedWord]
        
        self.updateView()
    }
    
    @IBAction func nextWord(_ sender: Any) {
        if (self.selectedWord == (self.mnemonic.count - 1)) {
            return self.performSegue(withIdentifier: "confirmPaperkey", sender: self)
        }
        
        self.selectedWord += 1
        self.wordLabel.text = self.mnemonic[self.selectedWord]
        
        self.updateView()
    }
    
    func showDoneButton() {
        self.nextButton.setTitle("Done", for: .normal)
        self.nextButton.setImage(UIImage(named: "ClipboardCheck"), for: .normal)
    }
    
    func showNextButton() {
        self.nextButton.setTitle("Next", for: .normal)
        self.nextButton.setImage(UIImage(named: "ArrowRight"), for: .normal)
    }
    
    func updateView() {
        self.progressionLabel.text = "\(self.selectedWord + 1) out of \(self.mnemonic.count)"
        
        if (self.selectedWord == 0) {
            self.hideButton(self.previousButton)
        }
        
        if (self.selectedWord > 0) {
            self.showButton(self.previousButton)
        }
        
        if (self.selectedWord == (self.mnemonic.count - 1)) {
            self.showDoneButton()
        } else {
            self.showNextButton()
        }
    }
    
    func hideButton(_ button: UIButton) {
        UIView.animate(withDuration: 0.3) {
            button.alpha = 0.5
            button.isEnabled = false
        }
    }
    
    func showButton(_ button: UIButton) {
        UIView.animate(withDuration: 0.3) {
            button.alpha = 1
            button.isEnabled = true
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        super.prepare(for: segue, sender: sender)
        
        if (segue.identifier == "confirmPaperkey") {
            let vc = segue.destination as! ConfirmPaperkeyViewController
            vc.mnemonic = self.mnemonic
        }
    }

    @objc func dismissView(_ sender: Any) {
        dismiss(animated: true)
    }

}
