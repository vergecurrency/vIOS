//
//  HomeView.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 01/09/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading) {

                LargeTitle(content: "Stats")
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                
                ChartView()
                
                Title(content: "Wallets")
                    .foregroundColor(.white)
                    .padding([.horizontal, .top], 30)
                
                WalletCardsView()
                
                Title(content: "More stats")
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                
                StatsCardsView()

                Spacer()
            }
        }
        .padding(.top, 30)
        .background(GradientBackgroundView())
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
