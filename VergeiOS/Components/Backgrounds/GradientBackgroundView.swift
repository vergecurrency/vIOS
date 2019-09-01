//
//  GradientBackgroundView.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 01/09/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import SwiftUI

struct GradientBackgroundView: View {
    let blurRadius: CGFloat = 0
    
    let gradient = LinearGradient(
        gradient: Gradient(colors: Color.blueGradient()),
        startPoint: .top,
        endPoint: UnitPoint(x: 0.5, y: 0.8)
    )
    
    var body: some View {
        ZStack {
            Image("Watermark")
                .resizable()
                .scaledToFill()
                .clipped()
                .frame(alignment: .center)
                .blendMode(.screen)
                .blur(radius: self.blurRadius)
                .background(self.gradient)
        }
            .edgesIgnoringSafeArea([.top, .bottom])
    }
}

struct GradientBackgroundView_Previews: PreviewProvider {
    static var previews: some View {
        GradientBackgroundView()
    }
}
