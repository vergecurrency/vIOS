//
//  StatsCardsView.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 13/09/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import SwiftUI

struct StatsCardsView: View {
    let items = [1,2,3]
    
    var maxWidth: CGFloat {
        return UIScreen.main.bounds.width * 0.75
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 30) {
                StatsCard(alignment: .leading) {
                    VStack(alignment: .leading) {
                        Subheadline(content: "Volume last 24H")
                            .foregroundColor(.primaryDark())
                    }
                        .padding(25)
                }
                
                StatsCard(alignment: .leading) {
                    VStack {
                        Text("Text")
                        Text("Text")
                    }
                }
            }
            .padding([.leading, .bottom, .trailing], 30)
            .padding(.top, 10)
        }
    }
}

struct StatsCard<Content>: View where Content: View {
    let alignment: HorizontalAlignment
    let spacing: CGFloat?
    let content: () -> Content

    @inlinable init(alignment: HorizontalAlignment = .center, spacing: CGFloat? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.alignment = alignment
        self.spacing = spacing
        self.content = content
    }
    
    var maxWidth: CGFloat {
        return UIScreen.main.bounds.width * 0.75
    }

    var body: some View {
        VStack(alignment: self.alignment, spacing: self.spacing, content: self.content)
            .frame(
                minWidth: 200,
                idealWidth: self.maxWidth > 350 ? 350 : self.maxWidth,
                maxWidth: 350,
                minHeight: 190,
                idealHeight: 190,
                maxHeight: 190
            )
            .background(Color.backgroundWhite())
            .cornerRadius(30)
            .shadow(radius: 10, y: 10)
    }
}

struct StatsCardsView_Previews: PreviewProvider {
    static var previews: some View {
        StatsCardsView()
    }
}
