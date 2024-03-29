//
//  WalletViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 31-07-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit
import SwiftyJSON

class WalletViewController: ThemeableViewController, UIScrollViewDelegate {

    @IBOutlet weak var backgroundView: WalletContainerView!
    @IBOutlet weak var walletNotificationView: WalletNotificationView!
    @IBOutlet weak var xvgBalanceLabel: UILabel!
    @IBOutlet weak var pairBalanceLabel: UILabel!
    @IBOutlet weak var pairSymbolBalanceLabel: UILabel!
    @IBOutlet weak var xvgPairBalanceLabel: UILabel!
    @IBOutlet weak var xvgPairSymbolLabel: UILabel!
    @IBOutlet weak var walletSlideScrollView: UIScrollView!
    @IBOutlet weak var walletSlidePageControl: UIPageControl!

    var applicationRepository: ApplicationRepository!
    private var walletSlides: [WalletSlideView] = []
    private var pageBeforeLayoutSubviews: Int?

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupSlides()
        self.setStats()

        NotificationCenter.default.post(name: .didLoadWalletViewController, object: self)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveStats(notification:)),
            name: .didReceiveFiatRatings,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didChangeWalletAmount(notification:)),
            name: .didChangeWalletAmount,
            object: nil
        )
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        self.pageBeforeLayoutSubviews = Int(
            round(self.walletSlideScrollView.contentOffset.x / self.walletSlideScrollView.frame.width)
        )
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        DispatchQueue.main.async {
            self.setupWalletSlideScrollView()

            if let page = self.pageBeforeLayoutSubviews {
                self.walletSlideScrollView.scrollRectToVisible(self.walletSlides[page].frame, animated: false)
            }
        }
    }

    func setupSlides() {
        self.walletSlideScrollView.delegate = self
        self.walletSlides = self.createWalletSlides()

        DispatchQueue.main.async {
            self.setupWalletSlideScrollView()

            for slide in self.walletSlides {
                self.walletSlideScrollView.addSubview(slide)
            }
        }
    }

    // MARK: - Wallet Scroll View

    func createWalletSlides() -> [WalletSlideView] {
        let transactionsSlide = Bundle.main.loadNibNamed(
            "TransactionsWalletSlideView",
            owner: self,
            options: nil
        )?.first as! WalletSlideView
        let chartSlide = Bundle.main.loadNibNamed(
            "ChartWalletSlideView",
            owner: self,
            options: nil
        )?.first as! WalletSlideView
        let summarySlide = Bundle.main.loadNibNamed(
            "SummaryWalletSlideView",
            owner: self,
            options: nil
        )?.first as! WalletSlideView

        return [
            transactionsSlide,
            chartSlide,
            summarySlide
        ]
    }

    func setupWalletSlideScrollView() {
        walletSlideScrollView.setNeedsDisplay()
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
            walletSlides[i].setNeedsDisplay()
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView == walletSlideScrollView) {
            let currentPage = Int(round(walletSlideScrollView.contentOffset.x/walletSlideScrollView.frame.width))
            self.walletSlidePageControl.currentPage = currentPage
        }
    }

    @objc func didReceiveStats(notification: Notification? = nil) {
        setStats()
    }

    @objc func didChangeWalletAmount(notification: Notification? = nil) {
        setStats()
    }

    func setStats() {
        DispatchQueue.main.async {
            let walletAmount = self.applicationRepository.amount
            self.xvgBalanceLabel.text = self.applicationRepository.amount.toXvgCurrency()

            if let xvgInfo = self.applicationRepository.latestRateInfo {
                self.pairBalanceLabel.text = NSNumber(value: walletAmount.doubleValue * xvgInfo.price).toCurrency()
                self.pairSymbolBalanceLabel.text =
                    "\(self.applicationRepository.currency) " + "wallet.balanceTitle".localized

                self.xvgPairBalanceLabel.text = NSNumber(value: xvgInfo.price).toPairCurrency(fractDigits: 6)
                self.xvgPairSymbolLabel.text = "\(self.applicationRepository.currency)/XVG"
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TransactionTableViewController" {
            if let nc = segue.destination as? UINavigationController {
                if let vc = nc.viewControllers.first as? TransactionTableViewController {
                    vc.transaction = sender as? Vws.TxHistory
                }
            }
        }
    }
}
