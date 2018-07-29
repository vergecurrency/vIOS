//
//  PaperKeyWordsViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 29-07-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class PaperKeyWordsViewController: AbstractPaperkeyViewController {
    
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var progressionLabel: UILabel!
    @IBOutlet weak var previousButton: RoundedButton!
    @IBOutlet weak var nextButton: RoundedButton!
    
    var words: [String] = [
        "words",
        "coming",
        "from",
        "the",
        "insight",
        "api",
        "verge",
        "is",
        "freking",
        "awesome",
        "wen",
        "moon"
    ]
    var selectedWord = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.wordLabel.text = self.words.first
        
        self.updateView()
    }
    
    @IBAction func previousWord(_ sender: Any) {
        self.selectedWord -= 1
        self.wordLabel.text = self.words[self.selectedWord]
        
        self.updateView()
    }
    
    @IBAction func nextWord(_ sender: Any) {
        if (self.selectedWord == (self.words.count - 1)) {
            return self.performSegue(withIdentifier: "confirmPaperkey", sender: self)
        }
        
        self.selectedWord += 1
        self.wordLabel.text = self.words[self.selectedWord]
        
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
        self.progressionLabel.text = "\(self.selectedWord + 1) out of \(self.words.count)"
        
        if (self.selectedWord == 0) {
            self.hideButton(self.previousButton)
        }
        
        if (self.selectedWord > 0) {
            self.showButton(self.previousButton)
        }
        
        if (self.selectedWord == (self.words.count - 1)) {
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
            vc.words = self.words
        }
    }

}
