//
//  SendView.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 01/09/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import SwiftUI

struct SendView: View {
    @State var address: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                VStack {
                    Card()
                    Spacer()
                }
                .padding(30)
            }
            .navigationBarTitle(Text("Send"))
        }
    }
}

struct Card: View {
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Image("SendCard")
                .resizable()
                .scaledToFit()
            VStack(alignment: .trailing) {
                Text("1,434,839.03 XVG")
                    .font(Font.avenir(size: 26, weight: .semibold))
                    .foregroundColor(.white)
                Text("€ 10,034,44")
                    .font(Font.avenir(size: 16, weight: .semibold))
                    .foregroundColor(.white)
            }
                .padding(25)
        }
    }
}

struct SendView_Previews: PreviewProvider {
    static var previews: some View {
        SendView()
    }
}
