//
//  UIViewController+Swipeable.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 12-08-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

extension UIViewController {

    // MARK: IS SWIPABLE - FUNCTION
    func isSwipable() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        self.view.addGestureRecognizer(panGestureRecognizer)
    }

    // MARK: HANDLE PAN GESTURE - FUNCTION
    @objc func handlePanGesture(_ sender: UIPanGestureRecognizer) {

        let percentThreshold: CGFloat = 0.3
        let translation = sender.translation(in: view)

        let newY = ensureRange(value: view.frame.minY + translation.y, minimum: 0, maximum: view.frame.maxY)
        let progress = progressAlongAxis(newY, view.bounds.height)

        view.frame.origin.y = newY //Move view to new position

        if sender.state == .ended {
            let velocity = sender.velocity(in: view)
            if velocity.y >= 300 || progress > percentThreshold {
                self.dismiss(animated: true) //Perform dismiss
            } else {
                UIView.animate(withDuration: 0.2, animations: {
                    self.view.frame.origin.y = 0 // Revert animation
                })
            }
        }

        sender.setTranslation(.zero, in: view)
    }
}

func progressAlongAxis(_ pointOnAxis: CGFloat, _ axisLength: CGFloat) -> CGFloat {
    let movementOnAxis = pointOnAxis / axisLength
    let positiveMovementOnAxis = fmaxf(Float(movementOnAxis), 0.0)
    let positiveMovementOnAxisPercent = fminf(positiveMovementOnAxis, 1.0)
    return CGFloat(positiveMovementOnAxisPercent)
}

func ensureRange<T>(value: T, minimum: T, maximum: T) -> T where T: Comparable {
    return min(max(value, minimum), maximum)
}
