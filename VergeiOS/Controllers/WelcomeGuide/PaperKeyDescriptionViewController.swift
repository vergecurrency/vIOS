//
//  PaperKeyDescriptionViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 26-07-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class PaperKeyDescriptionViewController: AbstractPaperkeyViewController {

    @IBOutlet weak var paperKeyIcon: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        stylePaperKeyIntro()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        stylePaperKeyIntro()
        self.paperKeyIcon.alpha = 0.0
        self.paperKeyIcon.center.y -= 20.0

        UIView.animate(withDuration: 0.3, delay: 0.2, options: .curveEaseInOut, animations: {
            self.paperKeyIcon.alpha = 1.0
            self.paperKeyIcon.center.y += 20.0
        }, completion: nil)
    }

    // Dismiss the view
    @IBAction func backToWelcome(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    private func stylePaperKeyIntro() {
        view.backgroundColor = ThemeManager.shared.backgroundGrey()
        paperKeyIcon.tintColor = ThemeManager.shared.primaryLight()

        for label in allLabels(in: view) {
            label.textColor = ThemeManager.shared.secondaryLight()
            label.shadowColor = UIColor.black.withAlphaComponent(0.35)
            label.shadowOffset = CGSize(width: 0, height: 1)
        }

        for button in allButtons(in: view) {
            button.setTitleColor(.white, for: .normal)
            button.tintColor = .white
            button.backgroundColor = ThemeManager.shared.primaryLight()
            button.layer.shadowColor = ThemeManager.shared.primaryLight().cgColor
            button.layer.shadowOpacity = 0.35
            button.layer.shadowRadius = 12
            button.layer.shadowOffset = CGSize(width: 0, height: 0)
        }
    }

    private func allLabels(in root: UIView) -> [UILabel] {
        var labels = [UILabel]()
        for subview in root.subviews {
            if let label = subview as? UILabel {
                labels.append(label)
            }
            labels.append(contentsOf: allLabels(in: subview))
        }
        return labels
    }

    private func allButtons(in root: UIView) -> [UIButton] {
        var buttons = [UIButton]()
        for subview in root.subviews {
            if let button = subview as? UIButton {
                buttons.append(button)
            }
            buttons.append(contentsOf: allButtons(in: subview))
        }
        return buttons
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        super.prepare(for: segue, sender: sender)
    }

}
