//
//  TorViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 05/12/2018.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class TorViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.delegate = self

        let slide1 = Bundle.main.loadNibNamed("TorSetup1View", owner: self, options: nil)?.first as! UIView
        let slide2 = Bundle.main.loadNibNamed("TorSetup2View", owner: self, options: nil)?.first as! UIView
        let slide3 = Bundle.main.loadNibNamed("TorSetup3View", owner: self, options: nil)?.first as! TorSetup3View
        slide3.viewController = self

        DispatchQueue.main.async {
            self.scrollView.contentSize = CGSize(
                width: self.scrollView.frame.width * 3,
                height: self.scrollView.frame.height
            )

            let width = self.scrollView.frame.width

            slide1.frame = CGRect(x: 0, y: 0, width: width, height: self.scrollView.frame.height)
            slide2.frame = CGRect(x: width, y: 0, width: width, height: self.scrollView.frame.height)
            slide3.frame = CGRect(x: width * 2, y: 0, width: width, height: self.scrollView.frame.height)

            [slide1, slide2].forEach { self.applyReadableTheme(to: $0) }
            self.scrollView.addSubview(slide1)
            self.scrollView.addSubview(slide2)
            self.scrollView.addSubview(slide3)
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView == scrollView) {
            pageControl.currentPage = Int(round(scrollView.contentOffset.x / scrollView.frame.width))
        }
    }

    @IBAction func closeView(_ sender: Any) {
        dismiss(animated: true)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

    private func applyReadableTheme(to root: UIView) {
        root.backgroundColor = UIColor(rgb: 0x080212)

        for subview in root.subviews {
            if let label = subview as? UILabel {
                label.textColor = label.font.pointSize >= 20
                    ? ThemeManager.shared.primaryLight()
                    : ThemeManager.shared.secondaryLight()
                label.backgroundColor = .clear
            } else if let textView = subview as? UITextView {
                textView.textColor = ThemeManager.shared.secondaryLight()
                textView.backgroundColor = .clear
            } else if !(subview is UIImageView) && !(subview is UISwitch) {
                subview.backgroundColor = .clear
            }

            if !(subview is UIControl) {
                applyReadableTheme(to: subview)
            }
        }
    }

}
