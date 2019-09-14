//
//  TransactionCellView.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 09/09/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import SwiftUI

struct TransactionCellView: View {
    var body: some View {
        HStack(spacing: 12) {
            Image("Received").layoutPriority(1)
            
            VStack(alignment: .leading, spacing: 5) {
                Text("DJjkiodjsoidj9j902jd2jde90d2jd0j2")
                    .font(.avenir(size: 14, weight: .semibold))
                    .foregroundColor(.secondaryLight())
                Text("9 sep. 2019 16:09")
                    .font(.avenir(size: 12, weight: .medium))
                    .foregroundColor(.vergeGrey())
            }
            
            Text("+ 434,45 XVG")
                .font(.avenir(size: 14, weight: .semibold))
                .foregroundColor(Color.vergeGreen())
                .layoutPriority(1)
        }.lineLimit(1)
    }
}

struct TransactionCellView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionCellView()
    }
}
