//
//  ChartSelectorView.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 08/09/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import SwiftUI

struct ChartSelectorView: View {
    var body: some View {
        HStack(spacing: 20) {
            ChartSelectorItem(label: "1D")
            ChartSelectorItem(label: "1W")
            ChartSelectorItem(label: "1M")
            ChartSelectorItem(label: "3M")
            ChartSelectorItem(label: "6M")
            ChartSelectorItem(label: "1Y")
            ChartSelectorItem(label: "ALL")
        }
        .frame(
            minWidth: 0,
            maxWidth: .infinity,
            minHeight: 0,
            maxHeight: .infinity,
            alignment: .center
        )
        .padding(.horizontal, 30)
    }
}

struct ChartSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        ChartSelectorView()
    }
}
