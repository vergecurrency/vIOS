//
//  ConfirmPaperkeyViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 29-07-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class ConfirmPaperkeyViewController: AbstractPaperkeyViewController {

    @IBOutlet weak var firstWordLabel: UILabel!
    @IBOutlet weak var secondWordLabel: UILabel!
    
    @IBOutlet weak var firstWordTextfield: UITextField!
    @IBOutlet weak var secondWordTextfield: UITextField!
    
    var words: [String] = []
    var randomNumbers: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(self.words)
        
        self.randomNumbers = self.selectRandomNumbers()
        
        self.firstWordLabel.text = "Word #\(randomNumbers.first!)"
        self.secondWordLabel.text = "Word #\(randomNumbers.last!)"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    @IBAction func submitPaperkeyConfirmation(_ sender: Any) {
        self.firstWordTextfield.backgroundColor = .white
        
        // Add shake effect...
        if (self.firstWordTextfield.text != self.words[self.randomNumbers.first! - 1]) {
            self.firstWordTextfield.backgroundColor = UIColor.vergeRed().withAlphaComponent(0.15)
            return
        }
        
        if (self.secondWordTextfield.text != self.words[self.randomNumbers.last! - 1]) {
            self.secondWordTextfield.backgroundColor = UIColor.vergeRed().withAlphaComponent(0.15)
            return
        }
        
        self.performSegue(withIdentifier: "submitPaperkeyViewController", sender: self)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        super.prepare(for: segue, sender: sender)
    }

}
