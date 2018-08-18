//
//  WalletViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 31-07-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit
import SwiftyJSON

class WalletViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var balanceScrollView: UIScrollView!
    @IBOutlet weak var balancePageControl: UIPageControl!
    @IBOutlet weak var blockchainStatusLabelView: UILabel!
    @IBOutlet weak var xvgFiatPriceLabelView: UILabel!
    @IBOutlet weak var xvgFiatLabel: UILabel!
    @IBOutlet weak var walletSlideScrollView: UIScrollView!
    @IBOutlet weak var walletSlidePageControl: UIPageControl!
    
    var balanceSlides: [BalanceSlide] = []
    var walletSlides: [WalletSlideView] = []

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupSlides()
        self.setStats()

        DispatchQueue.main.async {
            // Set the balance scroll view current page to users defaults.
            self.balanceScrollView.setCurrent(page: WalletManager.default.currentBalanceSlide)
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveStats(notification:)),
            name: .didReceiveStats,
            object: nil
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    func setupSlides() {
        self.balanceScrollView.delegate = self
        self.balanceSlides = self.createBalanceSlides()
        
        self.walletSlideScrollView.delegate = self
        self.walletSlides = self.createWalletSlides()
        
        DispatchQueue.main.async {
            self.setupBalanceSlideScrollView()
            self.setupWalletSlideScrollView()
            
            for slide in self.balanceSlides {
                self.balanceScrollView.addSubview(slide)
            }
            
            for slide in self.walletSlides {
                self.walletSlideScrollView.addSubview(slide)
            }
        }
    }
    
    
    // MARK: - Balance Scroll View
    
    func createBalanceSlides() -> [BalanceSlide] {
        let xvgBalance = Bundle.main.loadNibNamed("XVGBalanceView", owner: self, options: nil)?.first as! XVGBalanceView
        let fiatBalance = Bundle.main.loadNibNamed("FiatBalanceView", owner: self, options: nil)?.first as! FiatBalanceView
        let placeholderBalance = Bundle.main.loadNibNamed("PlaceholderView", owner: self, options: nil)?.first as! PlaceholderView
        
        return [
            xvgBalance,
            fiatBalance,
            placeholderBalance
        ]
    }
    
    func setupBalanceSlideScrollView() {
        let contentSizeWidth = balanceScrollView.frame.width * CGFloat(balanceSlides.count)

        balanceScrollView.contentSize = CGSize(width: contentSizeWidth, height: balanceScrollView.frame.height)
        
        for i in 0 ..< balanceSlides.count {
            let slideX = balanceScrollView.frame.width * CGFloat(i)
            let slideWidth = balanceScrollView.frame.width
            
            balanceSlides[i].frame = CGRect(x: slideX, y: 0, width: slideWidth, height: balanceScrollView.frame.height)
        }
    }
    
    
    // MARK: - Wallet Scroll View
    
    func createWalletSlides() -> [WalletSlideView] {
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
        walletSlideScrollView.contentSize = CGSize(
            width: walletSlideScrollView.frame.width * CGFloat(walletSlides.count),
            height: walletSlideScrollView.frame.height
        )
        
        for i in 0 ..< walletSlides.count {
            let slideX = walletSlideScrollView.frame.width * CGFloat(i)
            let slideWidth = walletSlideScrollView.frame.width
            
            walletSlides[i].frame = CGRect(
                x: slideX,
                y: 0,
                width: slideWidth,
                height: walletSlideScrollView.frame.height
            )
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView == balanceScrollView) {
            let currentPage = Int(round(balanceScrollView.contentOffset.x/balanceScrollView.frame.width))
            self.balancePageControl.currentPage = currentPage

            DispatchQueue.main.async {
                // Save the balance slide current page.
                WalletManager.default.currentBalanceSlide = currentPage
            }
        }
        
        if (scrollView == walletSlideScrollView) {
            let currentPage = Int(round(walletSlideScrollView.contentOffset.x/walletSlideScrollView.frame.width))
            self.walletSlidePageControl.currentPage = currentPage
        }
    }

    @objc func deviceRotated() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.setupWalletSlideScrollView()
        }
    }
    
    @objc func didReceiveStats(notification: Notification? = nil) {
        self.setStats()
    }
    
    func setStats() {
        DispatchQueue.main.async {
            if let xvgInfo = PriceTicker.shared.xvgInfo {
                self.xvgFiatPriceLabelView.text = xvgInfo.display.price
                self.xvgFiatLabel.text = "\(WalletManager.default.currency)/XVG"
            }
        }
    }

}
