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
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 220, maxHeight: .infinity, alignment: .center)
        .background(Color.black.blendMode(.overlay).opacity(0.6))
        .background(Color.purple.blendMode(.saturation).opacity(0.5))
        .background(BlurBackgroundView(style: .systemThinMaterial))
        .cornerRadius(30)
        .padding(.horizontal, 30)
        .shadow(color: Color.black.opacity(0.1), radius: 10, y: 10)
    }
}

struct ChartView_Previews: PreviewProvider {
    static var previews: some View {
        ChartView()
    }
}
