//
//  ThemeFactory.swift
//  VergeiOS
//
//  Created by Ivan Manov on 21.06.2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import Foundation
import UIKit

class ThemeFactory: NSObject {
    static let shared = ThemeFactory()

    var appIcons: [AppIcon] {
        return [featherAppIcon, moonAppIcon, marsAppIcon]
    }

    var themes: [Theme] {
        return [featherMode, moonMode, marsMode]
    }

    var featherMode: Theme {
        var featherMode = Theme(name: "settings.themes.featherMode".localized,
                                id: "featherMode",
                                icon: UIImage(named: "Feather")!,

                                primaryDark: UIColor(rgb: 0x112034),
                                primaryLight: UIColor(rgb: 0x37BCE1),
                                secondaryDark: UIColor(rgb: 0x183C54),
                                secondaryLight: UIColor(rgb: 0x637885),
                                backgroundBlue: UIColor(rgb: 0xDCEFFC),
                                backgroundGrey: UIColor(rgb: 0xF8F7F7),
                                backgroundWhite: UIColor(rgb: 0xFFFFFF),

                                separatorColor: UIColor(red: 0.85, green: 0.85, blue: 0.9, alpha: 1),
                                placeholderColor: UIColor(rgb: 0x000000).withAlphaComponent(0.3),
                                backgroundTopColor: UIColor(red: 0.39, green: 0.80, blue: 0.86, alpha: 1.0),
                                backgroundBottomColor: UIColor(rgb: 0x37BCE1),
                                qrCodeColor: UIColor(red: 0.11, green: 0.62, blue: 0.83, alpha: 1.0),
                                priceChartColor: UIColor.white.withAlphaComponent(0),

                                vergeGrey: UIColor(rgb: 0x9B9B9B),
                                vergeGreen: UIColor(rgb: 0x008570),
                                vergeRed: UIColor(rgb: 0xFF5252),

                                barStyle: .default,
                                statusBarStyle: .default,
                                isTranslucent: true,
                                keyboardAppearance: .default,

                                unlockBackgroundImage: UIImage(named: "UnlockBackground")!,
                                noBalancePlaceholderImage: UIImage(named: "NoBalancePlaceholder")!,
                                noContactsPlaceholderImage: UIImage(named: "NoContactsPlaceholder")!,
                                transactionsPlaceholderImage: UIImage(named: "TransactionsPlaceholder")!,
                                sendCardImage: UIImage(named: "SendCard")!,
                                receiveCardImage: UIImage(named: "ReceiveCard")!,
                                creditsImage: UIImage(named: "Hero")!,
                                appIconName: "AppIconFeather")

        if #available(iOS 13.0, *) {
            featherMode.statusBarStyle = .darkContent
        }

        return featherMode
    }

    private var moonMode: Theme {
        let moonMode = Theme(name: "settings.themes.moonMode".localized,
                             id: "moonMode",
                             icon: UIImage(named: "Moon")!,

                             primaryDark: UIColor(rgb: 0xDCEFFC),
                             primaryLight: UIColor(rgb: 0x37BCE1),
                             secondaryDark: UIColor(rgb: 0xF8F7F7),
                             secondaryLight: UIColor(rgb: 0x738FA0),
                             backgroundBlue: UIColor(rgb: 0x113354),
                             backgroundGrey: UIColor(rgb: 0x101e2e),
                             backgroundWhite: UIColor(rgb: 0x19293c),

                             separatorColor: UIColor(rgb: 0x3F5266),
                             placeholderColor: UIColor(rgb: 0x384350),
                             backgroundTopColor: UIColor(rgb: 0x09131e),
                             backgroundBottomColor: UIColor(rgb: 0x0C1928),
                             qrCodeColor: UIColor(rgb: 0x101e2e),
                             priceChartColor: UIColor(rgb: 0x19293c).withAlphaComponent(0),

                             vergeGrey: UIColor(rgb: 0x3F5266),
                             vergeGreen: UIColor(rgb: 0x008570),
                             vergeRed: UIColor(rgb: 0xFF5252),

                             barStyle: .black,
                             statusBarStyle: .lightContent,
                             isTranslucent: false,
                             keyboardAppearance: .dark,

                             unlockBackgroundImage: UIImage(named: "UnlockBackgroundMoonMode")!,
                             noBalancePlaceholderImage: UIImage(named: "NoBalancePlaceholderMoonMode")!,
                             noContactsPlaceholderImage: UIImage(named: "NoContactsPlaceholderMoonMode")!,
                             transactionsPlaceholderImage: UIImage(named: "TransactionsPlaceholderMoonMode")!,
                             sendCardImage: UIImage(named: "SendCardMoonMode")!,
                             receiveCardImage: UIImage(named: "ReceiveCardMoonMode")!,
                             creditsImage: UIImage(named: "HeroMoonMode")!,
                             appIconName: "AppIconMoon")

        return moonMode
    }

    private var marsMode: Theme {
        let marsMode = Theme(name: "settings.themes.marsMode".localized,
                             id: "marsMode",
                             icon: UIImage(named: "Mars")!,

                             primaryDark: UIColor(rgb: 0xDCEFFC),
                             primaryLight: UIColor(rgb: 0xFF5A25),
                             secondaryDark: UIColor(rgb: 0xF8F7F7),
                             secondaryLight: UIColor(rgb: 0x68261A),
                             backgroundBlue: UIColor(rgb: 0xFF5A25).withAlphaComponent(0.8),
                             backgroundGrey: UIColor(rgb: 0x000000),
                             backgroundWhite: UIColor(rgb: 0x140000),

                             separatorColor: UIColor(rgb: 0xCB5E3D),
                             placeholderColor: UIColor(rgb: 0x5A403F),
                             backgroundTopColor: .black,
                             backgroundBottomColor: .black,
                             qrCodeColor: UIColor(rgb: 0x2B0C01),
                             priceChartColor: .clear,

                             vergeGrey: UIColor(rgb: 0x886357),
                             vergeGreen: UIColor(rgb: 0x008570),
                             vergeRed: UIColor(rgb: 0xFF5252),

                             barStyle: .black,
                             statusBarStyle: .lightContent,
                             isTranslucent: false,
                             keyboardAppearance: .dark,

                             unlockBackgroundImage: UIImage(named: "UnlockBackgroundMarsMode")!,
                             noBalancePlaceholderImage: UIImage(named: "NoBalancePlaceholderMarsMode")!,
                             noContactsPlaceholderImage: UIImage(named: "NoContactsPlaceholderMarsMode")!,
                             transactionsPlaceholderImage: UIImage(named: "TransactionsPlaceholderMarsMode")!,
                             sendCardImage: UIImage(named: "SendCardMarsMode")!,
                             receiveCardImage: UIImage(named: "ReceiveCardMarsMode")!,
                             creditsImage: UIImage(named: "HeroMarsMode")!,
                             appIconName: "AppIconMars")

        return marsMode
    }

    private var featherAppIcon: AppIcon {
        let featherAppIcon = AppIcon(name: "Default",
                                     id: "AppIconFeather",
                                     icon: UIImage(named: "AppIconFeather")!)

        return featherAppIcon
    }

    private var moonAppIcon: AppIcon {
        let moonAppIcon = AppIcon(name: "Moon",
                                  id: "AppIconMoon",
                                  icon: UIImage(named: "AppIconMoon")!)

        return moonAppIcon
    }

    private var marsAppIcon: AppIcon {
        let marsAppIcon = AppIcon(name: "Mars",
                                  id: "AppIconMars",
                                  icon: UIImage(named: "AppIconMars")!)

        return marsAppIcon
    }
}

struct AppIcon {
    let name: String
    let id: String
    let icon: UIImage
}

struct Theme {
    let name: String
    let id: String
    let icon: UIImage

    let primaryDark: UIColor
    let primaryLight: UIColor

    let secondaryDark: UIColor
    let secondaryLight: UIColor

    let backgroundBlue: UIColor
    let backgroundGrey: UIColor
    let backgroundWhite: UIColor

    let separatorColor: UIColor
    let placeholderColor: UIColor
    let backgroundTopColor: UIColor
    let backgroundBottomColor: UIColor
    let qrCodeColor: UIColor
    let priceChartColor: UIColor

    let vergeGrey: UIColor
    let vergeGreen: UIColor
    let vergeRed: UIColor

    let barStyle: UIBarStyle
    var statusBarStyle: UIStatusBarStyle
    let isTranslucent: Bool
    let keyboardAppearance: UIKeyboardAppearance

    let unlockBackgroundImage: UIImage
    let noBalancePlaceholderImage: UIImage
    let noContactsPlaceholderImage: UIImage
    let transactionsPlaceholderImage: UIImage
    let sendCardImage: UIImage
    let receiveCardImage: UIImage
    let creditsImage: UIImage
    let appIconName: String
}
