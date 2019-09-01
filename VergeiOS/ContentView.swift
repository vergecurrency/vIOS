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
    var body: some View {
        VStack(alignment: .leading) {
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
                    Button(action: openReceive) {
                        DefaultButton(text: Text("Receive"))
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
        
    }
    
    func openReceive() {
        
    }
}

struct DefaultButton: View {
    let text: Text
    
    var body: some View {
        HStack {
            text
                .foregroundColor(.primaryLight())
                .font(Font.avenir(size: 16, weight: .medium))
        }
            .frame(
                minWidth: 0,
                maxWidth: .infinity,
                minHeight: 20,
                maxHeight: 20,
                alignment: .center
            )
            .padding(10)
            .background(Color.backgroundGrey())
            .cornerRadius(5)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
