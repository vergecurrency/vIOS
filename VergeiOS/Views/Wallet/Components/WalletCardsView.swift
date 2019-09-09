//
//  WalletCardsView.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 08/09/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import SwiftUI

struct WalletCardsView: View {
    let wallets = [
       Wallet(name: "MAIN ACCOUNT", amount: 1434839.03),
       Wallet(name: "BUSINESS ACCOUNT", amount: 31565789.23),
       Wallet(name: "SAVING ACCOUNT", amount: 44639.08)
    ]
    
    var maxWidth: CGFloat {
        return UIScreen.main.bounds.width * 0.75
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 30.0) {
                ForEach(self.wallets) { wallet in
                    GeometryReader { g in
                        WalletPanelView(wallet: wallet)
                            .frame(width: self.maxWidth)
                            .scaleEffect(g.frame(in: .global).minX < self.maxWidth ? 1 : 0.95, anchor: .trailing)
                            .offset(x: g.frame(in: .global).minX < self.maxWidth ? 0 : -10)
                            .animation(.spring())
                    }
                    .frame(
                        minWidth: 0,
                        idealWidth: self.maxWidth > 350 ? 350 : self.maxWidth,
                        maxWidth: 350,
                        minHeight: 280,
                        idealHeight: 280,
                        maxHeight: 280
                    )
                }
            }
            .padding([.leading, .bottom, .trailing], 30)
            .padding(.top, 10)
        }
    }
}

struct WalletCardsView_Previews: PreviewProvider {
    static var previews: some View {
        WalletCardsView()
    }
}
