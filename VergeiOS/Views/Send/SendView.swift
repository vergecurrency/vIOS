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
                Text("Send")
            }
            .navigationBarTitle(Text("Send"))
        }
    }
}

struct SendView_Previews: PreviewProvider {
    static var previews: some View {
        SendView()
    }
}
