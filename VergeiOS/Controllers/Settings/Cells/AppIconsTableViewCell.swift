//
//  AppIconsTableViewCell.swift
//  VergeiOS
//
//  Created by Ivan Manov on 06.07.2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import UIKit

class AppIconsTableViewCell: UITableViewCell {

    let appIcons = ThemeFactory.shared.appIcons
    var didAppIconSelected: ((_ appIcon: AppIcon) -> Void)?

    @IBOutlet weak var collectionView: UICollectionView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: false)
    }

}

extension AppIconsTableViewCell: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return self.appIcons.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "appIconCell",
                                                      for: indexPath) as! AppIconCollectionViewCell

        cell.titleLabel.text = self.appIcons[indexPath.row].name
        cell.imageView.image = self.appIcons[indexPath.row].icon

        return cell

    }

}

extension AppIconsTableViewCell: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.didAppIconSelected != nil {
            self.didAppIconSelected!(appIcons[indexPath.row])
        }
    }

}
