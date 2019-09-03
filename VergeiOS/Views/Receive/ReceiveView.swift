//
//  ReceiveView.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 01/09/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import SwiftUI

struct ReceiveView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Build it boy!")
                Spacer()
            }
            .navigationBarTitle(Text("Receive"))
        }
    }
}

struct ReceiveView_Previews: PreviewProvider {
    static var previews: some View {
        ReceiveView()
    }
}
