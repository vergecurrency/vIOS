//
//  ErrorView.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 22/03/2020.
//  Copyright © 2020 Verge Currency. All rights reserved.
//

import UIKit

class ErrorView: UIView {
    typealias RetryCompletion = () -> Void

    @IBOutlet weak var errorLabel: UILabel!

    var completion: RetryCompletion?

    static func showError(error: Error, bind to: UIView, completion: @escaping RetryCompletion) {
        guard let errorView = Bundle.main.loadNibNamed("ErrorView", owner: self)?.first as? ErrorView else {
            fatalError("Couldn't create ErrorView")
        }

        errorView.becomeThemeable()
        errorView.translatesAutoresizingMaskIntoConstraints = false
        errorView.errorLabel.text = error.localizedDescription

        to.addSubview(errorView)

        errorView.pinEdgesToSafeArea(to: to)
        errorView.onRetry {
            errorView.removeFromSuperview()

            completion()
        }
    }

    func onRetry(completion: @escaping RetryCompletion) {
        self.completion = completion
    }

    override func updateColors() {
        self.backgroundColor = ThemeManager.shared.currentTheme.backgroundGrey
    }

    @IBAction func retry(_ sender: UIButton) {
        guard let completion = completion else {
            return
        }

        completion()
    }

    @IBAction func askHelp(_ sender: UIButton) {
        let controller = UIStoryboard.createFromStoryboardWithNavigationController(
            name: "Settings",
            type: SupportTableViewController.self
        )

        guard let parent = self.parentContainerViewController() else {
            fatalError("Couldn't find parent container view controller")
        }

        parent.present(controller, animated: true)
    }
}
