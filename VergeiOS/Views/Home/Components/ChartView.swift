//
//  ChartView.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 08/09/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import SwiftUI

struct ChartView: View {
    var body: some View {
        VStack {
            Image("ChartPlaceholder")
                .resizable()
                .frame(
                    minWidth: 0,
                    maxWidth: .infinity,
                    minHeight: 190,
                    maxHeight: .infinity,
                    alignment: .center
                )
                .padding(.bottom, 15)
            ChartSelectorView()
        }
    }
}

struct ChartView_Previews: PreviewProvider {
    static var previews: some View {
        ChartView()
    }
}
