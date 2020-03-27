//
//  EdgedFormViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 27/03/2020.
//  Copyright © 2020 Verge Currency. All rights reserved.
//

import UIKit
import Eureka

class EdgedFormViewController: FormViewController {
    var scrollViewEdger: ScrollViewEdger!

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollViewEdger = ScrollViewEdger(scrollView: tableView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        scrollViewEdger.createShadowViews()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollViewEdger.updateView()
    }
}
