//
//  BlurBackgroundView.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 08/09/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import SwiftUI

struct BlurBackgroundView: UIViewRepresentable {
       
    let style: UIBlurEffect.Style
   
    func makeUIView(context: UIViewRepresentableContext<BlurBackgroundView>) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        let blurEffect = UIBlurEffect(style: style)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(blurView, at: 0)
        NSLayoutConstraint.activate([
            blurView.heightAnchor.constraint(equalTo: view.heightAnchor),
            blurView.widthAnchor.constraint(equalTo: view.widthAnchor),
        ])
        return view
    }
   
    func updateUIView(_ uiView: UIView,
                     context: UIViewRepresentableContext<BlurBackgroundView>) {}
}

struct BlurBackgroundView_Previews: PreviewProvider {
    static var previews: some View {
        BlurBackgroundView(style: .light)
    }
}
