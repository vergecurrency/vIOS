//
//  WalletView.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 09/09/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import SwiftUI

struct WalletView: View {
    let wallet: Wallet
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    NeonTitle(content: NSNumber(value: self.wallet.amount).toXvgCurrency())
                    Subheadline(content: "€ 10,034.44")
                        .foregroundColor(.primaryLight())
                }
                    .layoutPriority(1)
                Spacer()
            }
                .padding()
                .background(Color.backgroundGrey())
                .cornerRadius(20)
                .padding()
            List {
                Section(header: Text("Transactions")) {
                    TransactionCellView()
                    TransactionCellView()
                    TransactionCellView()
                    TransactionCellView()
                }
            }
        }
            .navigationBarTitle(Text(self.wallet.name))
            .navigationBarItems(trailing: Button(action: {
                //
            }) {
                Image("Settings")
                    .foregroundColor(.vergeGrey())
            })
    }
}

struct WalletView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            WalletView(wallet: Wallet(name: "Main Account", amount: 123234.43))
        }
    }
}
