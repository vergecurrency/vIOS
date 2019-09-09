//
//  WalletPanelView.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 01/09/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import SwiftUI

struct WalletPanelView: View {
    let wallet: Wallet?
    
    @State var showSend: Bool = false
    @State var showReceive: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            if wallet == nil {
                Image(systemName: "plus")
                    .font(.avenir(size: 50, weight: .black))
                    .foregroundColor(.secondaryLight())
                LargeTitle(content: "Add a wallet")
                    .foregroundColor(.secondaryLight())
            } else {
                VStack(alignment: .leading) {
                    Subheadline(content: self.wallet!.name.uppercased())
                        .foregroundColor(.primaryDark())
                    NeonTitle(content: NSNumber(value: self.wallet!.amount).toXvgCurrency())
                    Subheadline(content: "€ 10,034.44")
                        .foregroundColor(.primaryLight())
                }
                    .padding([.leading, .top, .trailing], 25)

                Spacer()

                Image("ChartLinePlaceholder")
                    .resizable()
                    .frame(
                        minWidth: 0,
                        maxWidth: 350,
                        minHeight: 100,
                        maxHeight: 100,
                        alignment: .center
                    )

                Spacer()

                VStack {
                    HStack {
                        Button(action: openSend) {
                            DefaultButton(text: Text("Send"))
                        }
                            .sheet(isPresented: self.$showSend) {
                                SendView()
                            }
                        Button(action: openReceive) {
                            DefaultButton(text: Text("Receive"))
                        }
                            .sheet(isPresented: self.$showReceive) {
                                ReceiveView()
                            }
                    }
                }
                    .padding([.leading, .bottom, .trailing], 25)
            }
        }
            .frame(
                minWidth: 0,
                maxWidth: 350,
                minHeight: 280,
                maxHeight: 280,
                alignment: self.wallet != nil ? .topLeading : .center
            )
            .background(Color.backgroundWhite())
            .cornerRadius(30)
            .shadow(radius: 10, y: 10)
    }
    
    func openSend() {
        self.showSend = true
    }
    
    func openReceive() {
        self.showReceive = true
    }
}

struct NeonTitle: View {
    let content: String
    let gradient: LinearGradient = LinearGradient(
        gradient: Gradient(colors: [Color.white.opacity(0), .white, Color(rgb: 0x6700FF).opacity(0)]),
        startPoint: .leading,
        endPoint: .trailing
    )
    
    var body: some View {
        Headline(content: self.content)
            .foregroundColor(.primaryDark())
            .background(
                Headline(content: self.content)
                    .foregroundColor(Color(rgb: 0x6700FF).opacity(0.25))
                    .offset(x: 0, y: 2)
            )
    }
}

struct WalletPanelView_Previews: PreviewProvider {
    static var previews: some View {
        WalletPanelView(wallet: Wallet(name: "Main Account", amount: 1020320.39))
    }
}
