//
//  ScrollViewEdger.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 17-09-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

// TODO: find a better solution for this whole class.
class ScrollViewEdger {
    
    var scrollView: UIScrollView!
    var topShadow: UIView!
    var bottomShadow: UIView!
    
    var hideTopShadow: Bool = false
    var hideBottomShadow: Bool = false
    
    let shadowHeight: CGFloat = 20.0
    let shadowAlpha: CGFloat = 0.1
    let animationDuration: Double = 0.2
    
    var verticalOffsetForBottom: CGFloat {
        let scrollViewHeight = scrollView.bounds.height
        let scrollContentSizeHeight = scrollView.contentSize.height
        let bottomInset = scrollView.contentInset.bottom
        let scrollViewBottomOffset = scrollContentSizeHeight + bottomInset - scrollViewHeight
        
        return scrollViewBottomOffset
    }
    
    init(scrollView: UITableView) {
        self.scrollView = scrollView
    }
    
    func createShadowViews() {
        if topShadow == nil {
            topShadow = UIView(frame: CGRect(x: 0, y: 0, width: scrollView.frame.size.width, height: shadowHeight))
            
            let gradientLayer = CAGradientLayer()
            gradientLayer.colors = [UIColor.gray.cgColor, UIColor.clear.cgColor]
            gradientLayer.frame = topShadow.frame
            
            topShadow.layer.insertSublayer(gradientLayer, at: 0)
            topShadow.alpha = 0.0
            
            scrollView.addSubview(topShadow)
        }
        
        if bottomShadow == nil {
            bottomShadow = UIView(frame: CGRect(
                x: 0,
                y: scrollView.bounds.size.height - scrollView.safeAreaInsets.bottom - shadowHeight,
                width: scrollView.frame.size.width,
                height: shadowHeight
            ))
            
            let gradientBottomLayer = CAGradientLayer()
            gradientBottomLayer.colors = [UIColor.gray.withAlphaComponent(0.0).cgColor, UIColor.gray.cgColor]
            gradientBottomLayer.frame = bottomShadow.frame
            
            bottomShadow.layer.insertSublayer(gradientBottomLayer, at: 0)
            bottomShadow.alpha = 0.0
            
            scrollView.addSubview(bottomShadow)
            
            DispatchQueue.main.async {
                self.updateView()
            }
        }
    }
    
    func updateView() {
        if topShadow == nil || bottomShadow == nil {
            return
        }
        
        if !hideTopShadow {
            topShadow.frame = CGRect(
                x: topShadow.frame.origin.x,
                y: scrollView.contentOffset.y,
                width: topShadow.frame.size.width,
                height: topShadow.frame.size.height
            )
            scrollView.bringSubviewToFront(topShadow)
            
            if scrollView.contentOffset.y > shadowHeight / 2 {
                UIView.animate(withDuration: animationDuration) {
                    self.topShadow.alpha = self.shadowAlpha
                }
            } else {
                UIView.animate(withDuration: animationDuration) {
                    self.topShadow.alpha = 0.0
                }
            }
        }
        
        if !hideBottomShadow {
            bottomShadow.frame = CGRect(
                x: bottomShadow.frame.origin.x,
                y: scrollView.contentOffset.y,
                width: bottomShadow.frame.size.width,
                height: bottomShadow.frame.size.height
            )
            scrollView.bringSubviewToFront(bottomShadow)
            
            if scrollView.contentOffset.y + shadowHeight / 2 >= verticalOffsetForBottom + scrollView.safeAreaInsets.bottom {
                UIView.animate(withDuration: animationDuration) {
                    self.bottomShadow.alpha = 0.0
                }
            } else {
                UIView.animate(withDuration: animationDuration) {
                    self.bottomShadow.alpha = self.shadowAlpha
                }
            }
        }
    }
}
