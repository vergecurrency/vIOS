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
        VStack(spacing: 15) {
            Image("ChartPlaceholder")
                .resizable()
                .frame(
                    minWidth: 0,
                    maxWidth: .infinity,
                    minHeight: 0,
                    maxHeight: 150,
                    alignment: .center
                )
                .blendMode(.hardLight)
                .layoutPriority(1)
            ChartSelectorView()
                .font(.avenir(size: 12, weight: .semibold))
        }
        .padding(.vertical, 15)
    }
}

struct ChartView_Previews: PreviewProvider {
    static var previews: some View {
        ChartView()
    }
}
