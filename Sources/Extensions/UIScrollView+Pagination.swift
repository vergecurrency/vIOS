//
//  UIScrollView+Pagination.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 16-08-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

extension UIScrollView {

    // Scroll to a page on the scroll view.
    func setCurrent(page: Int, animated: Bool = true) {
        let rect = CGRect(origin: CGPoint(x: self.frame.size.width * CGFloat(page), y: 0), size: self.frame.size)

        self.scrollRectToVisible(rect, animated: true)
    }

}
