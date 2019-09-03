//
//  Labels.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 01/09/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import SwiftUI

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
            .font(Font.avenir(size: 22, weight: .bold))
    }
}

struct Subheadline: View {
    let content: String

    var body: some View {
        Text(self.content)
            .font(Font.avenir(size: 12, weight: .bold))
    }
}
