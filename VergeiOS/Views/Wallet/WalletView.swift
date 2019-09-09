//
//  WalletView.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 01/09/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import SwiftUI

struct WalletView: View {
    var body: some View {
        VStack(alignment: .leading) {

            LargeTitle(content: "Stats")
                .foregroundColor(.white)
                .padding(.horizontal, 30)
            
            ChartView()
            
            Spacer()
            
            LargeTitle(content: "Wallets")
                .foregroundColor(.white)
                .padding(.horizontal, 30)
            
            WalletCardsView()
        }
        .padding(.top, 30)
        .background(GradientBackgroundView())
    }
}

struct WalletView_Previews: PreviewProvider {
    static var previews: some View {
        WalletView()
    }
}
