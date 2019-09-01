//
//  ContentView.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 01/09/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import SwiftUI

struct ContentView: View {
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

struct WalletPanel: View {
    @State var showSend: Bool = false
    @State var showReceive: Bool = false
    
    var body: some View {
        return VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Subheadline(content: "MAIN WALLET")
                    .foregroundColor(.primaryDark())
                Headline(content: NSNumber(value: 1434839.03).toXvgCurrency())
                    .foregroundColor(.primaryDark())
                Subheadline(content: "€ 10,034.44")
                    .foregroundColor(.primaryLight())
            }
            .padding([.leading, .top, .trailing], 25)
            Image("ChartLinePlaceholder")
                .resizable()
                .frame(
                    minWidth: 0,
                    maxWidth: .infinity,
                    minHeight: 100,
                    maxHeight: 100,
                    alignment: .center
                )
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
            .frame(
                minWidth: 0,
                maxWidth: .infinity,
                alignment: .topLeading
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
