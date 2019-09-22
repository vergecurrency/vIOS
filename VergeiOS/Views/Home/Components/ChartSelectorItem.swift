//
//  ChartSelectorItem.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 08/09/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import SwiftUI

struct ChartSelectorItem: View {
    let label: String
    
    var body: some View {
        Text(self.label)
            .foregroundColor(.white)
            .blendMode(.overlay)
            .font(Font.avenir(size: 15, weight: .semibold))
    }
}

struct ChartSelectorItem_Previews: PreviewProvider {
    static var previews: some View {
        ChartSelectorItem(label: "1H")
    }
}
