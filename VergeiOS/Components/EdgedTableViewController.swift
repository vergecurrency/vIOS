//
//  EdgedTableViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 13-09-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class EdgedTableViewController: UITableViewController {
    
    var topShadow: UIView!
    var bottomShadow: UIView!
    
    var verticalOffsetForBottom: CGFloat {
        let scrollViewHeight = tableView.bounds.height
        let scrollContentSizeHeight = tableView.contentSize.height
        let bottomInset = tableView.contentInset.bottom
        let scrollViewBottomOffset = scrollContentSizeHeight + bottomInset - scrollViewHeight

        return scrollViewBottomOffset
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topShadow = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 20))
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.gray.cgColor, UIColor.clear.cgColor]
        gradientLayer.frame = topShadow.frame
        
        topShadow.layer.insertSublayer(gradientLayer, at: 0)
        topShadow.alpha = 0.0
        
        view.addSubview(topShadow)
        
        bottomShadow = UIView(frame: CGRect(x: 0, y: 312, width: view.frame.size.width, height: 20))
        
        let gradientBottomLayer = CAGradientLayer()
        gradientBottomLayer.colors = [UIColor.gray.withAlphaComponent(0.0).cgColor, UIColor.gray.cgColor]
        gradientBottomLayer.frame = bottomShadow.frame
        
        bottomShadow.layer.insertSublayer(gradientBottomLayer, at: 0)
        bottomShadow.alpha = 0.0
        
        view.addSubview(bottomShadow)
        
        DispatchQueue.main.async {
            self.scrollViewDidScroll(self.tableView)
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        topShadow.frame = CGRect(
            x: topShadow.frame.origin.x,
            y: scrollView.contentOffset.y,
            width: topShadow.frame.size.width,
            height: topShadow.frame.size.height
        )
        view.bringSubview(toFront: topShadow)
        
        if scrollView.contentOffset.y > 10 {
            UIView.animate(withDuration: 0.2) {
                self.topShadow.alpha = 0.1
            }
        } else {
            UIView.animate(withDuration: 0.2) {
                self.topShadow.alpha = 0.0
            }
        }
        
        bottomShadow.frame = CGRect(
            x: bottomShadow.frame.origin.x,
            y: 312 + scrollView.contentOffset.y,
            width: bottomShadow.frame.size.width,
            height: bottomShadow.frame.size.height
        )
        view.bringSubview(toFront: bottomShadow)
        
        if tableView.contentOffset.y + 10 >= verticalOffsetForBottom + (tabBarController?.tabBar.frame.size.height ?? 0.0) {
            UIView.animate(withDuration: 0.2) {
                self.bottomShadow.alpha = 0.0
            }
        } else {
            UIView.animate(withDuration: 0.2) {
                self.bottomShadow.alpha = 0.1
            }
        }
    }
}
