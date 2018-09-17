//
//  EdgedTableViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 13-09-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class EdgedTableViewController: UITableViewController {
    
    var scrollViewEdger: ScrollViewEdger!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollViewEdger = ScrollViewEdger(scrollView: tableView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollViewEdger.createShadowViews()
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollViewEdger.updateView()
    }
}
