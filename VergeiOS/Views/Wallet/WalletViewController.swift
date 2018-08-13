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
    @IBOutlet weak var transactionsQuantityLabelView: UILabel!
    @IBOutlet weak var blockchainStatusLabelView: UILabel!
    @IBOutlet weak var xvgFiatPriceLabelView: UILabel!
    @IBOutlet weak var walletSlideScrollView: UIScrollView!
    @IBOutlet weak var walletSlidePageControl: UIPageControl!
    
    var balanceSlides: [BalanceSlide] = []
    var walletSlides: [WalletSlideView] = []
    
    var xvgInfo: XvgInfo?
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupSlides()
        self.setStats()
        
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveStats), name: .didReceiveStats, object: nil)
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
    
    func setupSlides() {
        self.balanceScrollView.delegate = self
        self.balanceSlides = self.createBalanceSlides()
        
        self.walletSlideScrollView.delegate = self
        self.walletSlides = self.createWalletSlides()
        
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            walletSlidePageControl.numberOfPages = 2
        }
        
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
        
        return [
            xvgBalance,
            fiatBalance
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
        var contentSizeWidth = walletSlideScrollView.frame.width * CGFloat(walletSlides.count)
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            contentSizeWidth = walletSlideScrollView.frame.width * 2
        }
        
        walletSlideScrollView.contentSize = CGSize(width: contentSizeWidth, height: walletSlideScrollView.frame.height)
        
        for i in 0 ..< walletSlides.count {
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
            
            walletSlides[i].frame = CGRect(x: slideX, y: 0, width: slideWidth, height: walletSlideScrollView.frame.height)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView == balanceScrollView) {
            self.balancePageControl.currentPage = Int(round(balanceScrollView.contentOffset.x/balanceScrollView.frame.width))
        }
        
        if (scrollView == walletSlideScrollView) {
            self.walletSlidePageControl.currentPage = Int(round(walletSlideScrollView.contentOffset.x/walletSlideScrollView.frame.width))
        }
    }
    
    @objc func deviceRotated() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.setupBalanceSlideScrollView()
            self.setupWalletSlideScrollView()
        }
    }
    
    @objc func didReceiveStats(_ notification: Notification) {
        self.setStats()
    }
    
    func setStats() {
        DispatchQueue.main.async {
            if let xvgInfo = PriceTicker.shared.xvgInfo {
                self.xvgFiatPriceLabelView.text = xvgInfo.display.price
            }
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
