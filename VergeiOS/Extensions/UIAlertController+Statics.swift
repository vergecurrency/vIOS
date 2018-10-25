//
// Created by Swen van Zanten on 25/10/2018.
// Copyright (c) 2018 Verge Currency. All rights reserved.
//

import UIKit

extension UIAlertController {
    static func createDeleteContactAlert(handler: ((UIAlertAction) -> Void)?) -> UIAlertController{
        let alert = UIAlertController(
            title: "Remove contact",
            message: "Are you sure you want to remove the contact?",
            preferredStyle: .alert
        )

        let delete = UIAlertAction(title: "Delete", style: .destructive, handler: handler)

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(delete)

        return alert
    }
}
