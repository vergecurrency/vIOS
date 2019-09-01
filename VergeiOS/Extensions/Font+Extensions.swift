//
//  Font+Extensions.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 01/09/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import SwiftUI

extension Font {
    static func avenir(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        self.custom("Avenir Next", size: size).weight(weight)
    }
}

struct LargeTitle: View {
    let content: String

    var body: some View {
        Text(self.content)
            .font(Font.avenir(size: 34, weight: .semibold))
    }
}

struct Title: View {
    let content: String

    var body: some View {
        Text(self.content)
            .font(Font.avenir(size: 24, weight: .semibold))
    }
}

struct Headline: View {
    let content: String

    var body: some View {
        Text(self.content)
            .font(Font.avenir(size: 20, weight: .bold))
    }
}

struct Subheadline: View {
    let content: String

    var body: some View {
        Text(self.content)
            .font(Font.avenir(size: 12, weight: .bold))
    }
}
