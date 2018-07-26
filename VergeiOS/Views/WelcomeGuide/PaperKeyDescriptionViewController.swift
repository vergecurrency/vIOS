//
//  PaperKeyDescriptionViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 26-07-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class PaperKeyDescriptionViewController: UIViewController {
    
    override func viewDidLoad() {
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
    }
    
    // Dismiss the view
    @IBAction func backToWelcome(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
