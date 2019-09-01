//
//  DefaultButton.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 01/09/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import SwiftUI

struct DefaultButton: View {
    let text: Text
    
    var body: some View {
        HStack {
            text
                .foregroundColor(.primaryLight())
                .font(Font.avenir(size: 16, weight: .medium))
        }
            .frame(
                minWidth: 0,
                maxWidth: .infinity,
                minHeight: 20,
                maxHeight: 20,
                alignment: .center
            )
            .padding(10)
            .background(Color.backgroundGrey())
            .cornerRadius(5)
    }
}

struct DefaultButton_Previews: PreviewProvider {
    static var previews: some View {
        DefaultButton(text: Text("My Button"))
    }
}
