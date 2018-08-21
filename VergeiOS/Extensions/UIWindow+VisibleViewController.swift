//
//  UIWindow+VisibleViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 20-08-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

extension UIWindow {
    
    func visibleViewController() -> UIViewController? {
        if let rootViewController: UIViewController = self.rootViewController {
            return UIWindow.getVisibleViewControllerFrom(vc: rootViewController)
        }
        
        return nil
    }
    
    class func getVisibleViewControllerFrom(vc: UIViewController) -> UIViewController? {
        if vc.isKind(of: UINavigationController.self) {
            let navigationController = vc as! UINavigationController
            return UIWindow.getVisibleViewControllerFrom( vc: navigationController.viewControllers.first!)
        } else if vc.isKind(of: UITabBarController.self) {
            let tabBarController = vc as! UITabBarController
            return UIWindow.getVisibleViewControllerFrom(vc: tabBarController.selectedViewController!)
        } else if vc.isKind(of: UIAlertController.self) {
            let tabBarController = vc as! UIAlertController
            return UIWindow.getVisibleViewControllerFrom(vc: tabBarController)
        } else {
            if let presentedViewController = vc.presentedViewController {
                if (presentedViewController.presentedViewController != nil) {
                    return UIWindow.getVisibleViewControllerFrom(vc: presentedViewController.presentedViewController!)
                } else {
                    return nil
                }
            } else {
                return vc;
            }
        }
    }
}
