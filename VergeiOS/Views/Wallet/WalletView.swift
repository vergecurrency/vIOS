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
            Image("ChartPlaceholder")
                .resizable()
                .frame(
                    minWidth: 0,
                    maxWidth: .infinity,
                    minHeight: 190,
                    maxHeight: .infinity,
                    alignment: .center
                )
            Spacer()
            ChartSelector()
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

struct ChartSelector: View {
    var body: some View {
        HStack(spacing: 20) {
            ChartSelectorItem(label: "1D")
            ChartSelectorItem(label: "1W")
            ChartSelectorItem(label: "1M")
            ChartSelectorItem(label: "3M")
            ChartSelectorItem(label: "6M")
            ChartSelectorItem(label: "1Y")
            ChartSelectorItem(label: "ALL")
        }
        .frame(
            minWidth: 0,
            maxWidth: .infinity,
            minHeight: 0,
            maxHeight: .infinity,
            alignment: .center
        )
        .padding(.horizontal, 30)
    }
}

struct ChartSelectorItem: View {
    let label: String
    
    var body: some View {
        Text(self.label)
            .foregroundColor(.white)
            .blendMode(.softLight)
            .font(Font.avenir(size: 15, weight: .semibold))
    }
}

struct WalletView_Previews: PreviewProvider {
    static var previews: some View {
        WalletView()
    }
}
