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
        ZStack(alignment: .topTrailing) {
            HomeView()
            MainSettingsButton()
        }
    }
}

struct MainSettingsButton: View {
    @State var showSettings: Bool = false
    
    var body: some View {
        HStack {
            Button(action: self.openSettings) {
                Image("Settings")
                    .foregroundColor(.white)
            }
            .sheet(isPresented: self.$showSettings) {
                SettingsView()
            }
        }.padding()
    }
    
    func openSettings() {
        self.showSettings = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
