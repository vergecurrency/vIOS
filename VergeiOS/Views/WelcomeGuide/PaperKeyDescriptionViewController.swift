//
//  PaperKeyDescriptionViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 26-07-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class PaperKeyDescriptionViewController: UIViewController {
    
    @IBOutlet weak var paperKeyIcon: UIImageView!
    
    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .lightContent
        
        self.paperKeyIcon.alpha = 0.0
        self.paperKeyIcon.center.y -= 60.0
        
        UIView.animate(withDuration: 0.3, delay: 08.2, options: .curveEaseInOut, animations: {
            self.paperKeyIcon.alpha = 1.0
            self.paperKeyIcon.center.y += 60.0
        }, completion: nil)
    }
    
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
