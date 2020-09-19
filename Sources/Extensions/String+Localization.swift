//
//  String+Localization.swift
//  VergeiOS
//
//  Created by Ivan Manov on 09/05/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import Foundation

extension String {
    var localized: String {
        let result = Bundle.main.localizedString(forKey: self, value: "_", table: nil)

        return (result == "_") ?  localizedDefault : result
    }

    private var localizedDefault: String {
        let bundle = self.bundleForLanguage(language: "en")
        return bundle?.localizedString(forKey: self, value: nil, table: nil) ?? self
    }

    private func bundleForLanguage(language code: String) -> Bundle? {
        guard let path = Bundle.main.path(forResource: code, ofType: "lproj") else {
            return nil
        }

        return Bundle(path: path)
    }
}
