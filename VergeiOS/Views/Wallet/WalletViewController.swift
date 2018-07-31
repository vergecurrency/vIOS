//
//  WalletViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 31-07-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class WalletViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var xvgAmountLabelView: UILabel!
    @IBOutlet weak var transactionsQuantityLabelView: UILabel!
    @IBOutlet weak var blockchainStatusLabelView: UILabel!
    @IBOutlet weak var xvgFiatPriceLabelView: UILabel!
    @IBOutlet weak var walletSlideScrollView: UIScrollView!
    @IBOutlet weak var walletSlidePageControl: UIPageControl!
    
    var slides: [WalletSlideView] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.walletSlideScrollView.delegate = self
        self.slides = self.createSlides()
        
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            walletSlidePageControl.numberOfPages = 2
        }
        
        DispatchQueue.main.async {
            self.setupWalletSlideScrollView()
            
            for slide in self.slides {
                self.walletSlideScrollView.addSubview(slide)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        NotificationCenter.default.addObserver(self, selector: #selector(deviceRotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Wallet Scroll View
    
    func createSlides() -> [WalletSlideView] {
        let transactionsSlide = Bundle.main.loadNibNamed("TransactionsWalletSlideView", owner: self, options: nil)?.first as! WalletSlideView
        let chartSlide = Bundle.main.loadNibNamed("SummaryWalletSlideView", owner: self, options: nil)?.first as! WalletSlideView
        let summarySlide = Bundle.main.loadNibNamed("ChartWalletSlideView", owner: self, options: nil)?.first as! WalletSlideView
        
        return [
            transactionsSlide,
            chartSlide,
            summarySlide
        ]
    }
    
    func setupWalletSlideScrollView() {
        var contentSizeWidth = walletSlideScrollView.frame.width * CGFloat(slides.count)
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            contentSizeWidth = walletSlideScrollView.frame.width * 2
        }
        
        walletSlideScrollView.contentSize = CGSize(width: contentSizeWidth, height: walletSlideScrollView.frame.height)
        
        for i in 0 ..< slides.count {
            var slideX = walletSlideScrollView.frame.width * CGFloat(i)
            var slideWidth = walletSlideScrollView.frame.width
            if (UIDevice.current.userInterfaceIdiom == .pad) {
                if (i == 0) {
                    slideX = 0
                    slideWidth = slideWidth - 300
                } else if (i == 1) {
                    slideX = slideWidth - 300
                    slideWidth = 300
                } else if (i == 2) {
                    slideX = slideWidth * 1
                }
            }
            
            slides[i].frame = CGRect(x: slideX, y: 0, width: slideWidth, height: walletSlideScrollView.frame.height)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.walletSlidePageControl.currentPage = Int(round(walletSlideScrollView.contentOffset.x/walletSlideScrollView.frame.width))
    }
    
    @objc func deviceRotated() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.setupWalletSlideScrollView()
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
