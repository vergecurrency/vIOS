//
// Created by Swen van Zanten on 14/10/2018.
// Copyright (c) 2018 Verge Currency. All rights reserved.
//

import UIKit

class ThemeManager {

    static let shared = ThemeManager()
    
    let appRepo = Application.container.resolve(ApplicationRepository.self)!

    var currentTheme : Theme {
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

    func initialize(withWindow window: UIWindow) {
        UITabBar.appearance().layer.borderWidth = 0
        UITabBar.appearance().layer.borderColor = UIColor.clear.cgColor
        UITabBar.appearance().clipsToBounds = true

        UITabBar.appearance().tintColor = self.primaryLight()
        UITabBar.appearance().unselectedItemTintColor = self.secondaryLight()
        UITabBar.appearance().barTintColor = self.backgroundGrey()
        UITabBar.appearance().backgroundColor = self.backgroundGrey()
        UITabBar.appearance().barStyle = self.barStyle()
        UITabBar.appearance().isTranslucent = self.currentTheme.isTranslucent

        UIToolbar.appearance().tintColor = self.primaryLight()
        UIToolbar.appearance().barTintColor = self.backgroundWhite()
        UIToolbar.appearance().backgroundColor = self.backgroundWhite()
        UIToolbar.appearance().barStyle = self.barStyle()
        UIToolbar.appearance().isTranslucent = self.currentTheme.isTranslucent

        UITableView.appearance().backgroundColor = self.backgroundGrey()
        UITableView.appearance().tintColor = self.primaryLight()
        UITableView.appearance().separatorColor = self.separatorColor()

        let colorView = UIView()
        colorView.backgroundColor = self.backgroundBlue()

        UITableViewCell.appearance().selectedBackgroundView = colorView
        UITableViewCell.appearance().backgroundColor = self.backgroundWhite()

        UITextField.appearance().textColor = self.secondaryDark()
        UITextField.appearance().keyboardAppearance = self.currentTheme.keyboardAppearance
        UISearchBar.appearance().keyboardAppearance = self.currentTheme.keyboardAppearance

        CloseButton.appearance().titleLabel?.textColor = self.secondaryDark()
        CloseButton.appearance().tintColor = self.secondaryDark()

        window.tintColor = self.primaryLight()
    }
    
    func switchTheme(theme: Theme) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        appRepo.currentTheme = theme.id
        appDelegate.restart()
        
        self.initialize(withWindow: appDelegate.window!)
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
