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
            VStack(alignment: .leading) {
                LargeTitle(content: "Stats")
                    .foregroundColor(.white)
            }
            .padding(30)
            Spacer()
            VStack(alignment: .leading) {
                Title(content: "Wallets")
                    .foregroundColor(.white)
                WalletPanel()
            }
            .padding([.top, .leading, .trailing], 30)
        }
        .background(GradientBackgroundView())
    }
}

struct WalletView_Previews: PreviewProvider {
    static var previews: some View {
        WalletView()
    }
}
