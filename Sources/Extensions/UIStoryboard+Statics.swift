//
//  UIStoryboard+Statics.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 31/03/2020.
//  Copyright © 2020 Verge Currency. All rights reserved.
//

import UIKit

extension UIStoryboard {
    static func createFromStoryboard<T>(name: String, type: T.Type) -> T {
        let controller = UIStoryboard(name: name, bundle: nil).instantiateViewController(
            withIdentifier: String(describing: type)
        )

        guard let typedController = controller as? T else {
            fatalError("Can't create \(String(describing: type)) from the Storyboard")
        }

        return typedController
    }

    static func createFromStoryboardWithNavigationController<T>(name: String, type: T.Type) -> UINavigationController {
        guard let controller = UIStoryboard.createFromStoryboard(name: name, type: type) as? UIViewController else {
            fatalError("Can't create \(String(describing: type)) from the Storyboard")
        }
        
        let navigationController = UINavigationController(rootViewController: controller)
        let closeButton = UIBarButtonItem(image: UIImage(named: "Close"), style: .plain) { _ in
            controller.dismiss(animated: true)
        }

        controller.navigationItem.setLeftBarButtonItems([closeButton], animated: false)

        return navigationController
    }
}
