//
//  WalletPanel.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 01/09/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import SwiftUI

struct WalletPanel: View {
    @State var showSend: Bool = false
    @State var showReceive: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Subheadline(content: "MAIN WALLET")
                    .foregroundColor(.primaryDark())
                NeonTitle(content: NSNumber(value: 1434839.03).toXvgCurrency())
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

struct WalletPanel_Previews: PreviewProvider {
    static var previews: some View {
        WalletPanel()
    }
}
