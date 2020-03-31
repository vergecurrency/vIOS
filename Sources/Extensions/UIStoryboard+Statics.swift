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

        guard let controlle = controller as? T else {
            fatalError("Can't create \(String(describing: type)) from the Storyboard")
        }

        return controlle
    }
}
