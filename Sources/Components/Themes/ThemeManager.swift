//
// Created by Swen van Zanten on 14/10/2018.
// Copyright (c) 2018 Verge Currency. All rights reserved.
//

import UIKit
import Logging

class ThemeManager {

    static let shared = ThemeManager()

    let appRepo = Application.container.resolve(ApplicationRepository.self)!

    var currentTheme: Theme {
        let themes = ThemeFactory.shared.themes
        if appRepo.currentTheme != nil {
            let index = themes.firstIndex(where: { (theme) -> Bool in
                theme.id == appRepo.currentTheme
            }) ?? 0

            return themes[index]
        } else {
            return themes.first!
        }
    }

    func switchTheme(theme: Theme) {
        appRepo.currentTheme = theme.id
    }

    func switchAppIcon(appIcon: AppIcon) {
        self.changeIcon(to: appIcon.id)
    }

    func changeIcon(to name: String?) {
        //Check if the app supports alternating icons
        guard UIApplication.shared.supportsAlternateIcons else {
            return
        }

        //Change the icon to a specific image with given name
        UIApplication.shared.setAlternateIconName(name) { error in
            //After app icon changed, log our error or success message
            guard let log = Application.container.resolve(Logger.self) else {
                return
            }

            guard let error = error else {
                return log.info("theme manager application icon changed successfully")
            }
            
            log.error("theme manager application icon change failed: \(error.localizedDescription)")
        }
    }

    // MARK: Styling

    func separatorColor() -> UIColor {
        return self.currentTheme.separatorColor
    }

    func priceChartColor() -> UIColor {
        return self.currentTheme.priceChartColor
    }

    func primaryDark() -> UIColor {
        return self.currentTheme.primaryDark
    }

    func primaryLight() -> UIColor {
        return self.currentTheme.primaryLight
    }

    func secondaryDark() -> UIColor {
        return self.currentTheme.secondaryDark
    }

    func secondaryLight() -> UIColor {
        return self.currentTheme.secondaryLight
    }

    func backgroundBlue() -> UIColor {
        return self.currentTheme.backgroundBlue
    }

    func backgroundGrey() -> UIColor {
        return self.currentTheme.backgroundGrey
    }

    func backgroundWhite() -> UIColor {
        return self.currentTheme.backgroundWhite
    }

    func vergeGrey() -> UIColor {
        return self.currentTheme.vergeGrey
    }

    func vergeGreen() -> UIColor {
        return self.currentTheme.vergeGreen
    }

    func vergeRed() -> UIColor {
        return self.currentTheme.vergeRed
    }

    func placeholderColor() -> UIColor {
        return self.currentTheme.placeholderColor
    }

    func backgroundTopColor() -> UIColor {
        return self.currentTheme.backgroundTopColor
    }

    func backgroundBottomColor() -> UIColor {
        return self.currentTheme.backgroundBottomColor
    }

    func barStyle() -> UIBarStyle {
        return self.currentTheme.barStyle
    }

    func statusBarStyle() -> UIStatusBarStyle {
        return self.currentTheme.statusBarStyle
    }
}
