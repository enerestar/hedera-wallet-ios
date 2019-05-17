//
//  LeftMenuCell.swift
//  HGCApp
//
//  Created by Surendra  on 26/10/17.
//  Copyright © 2017 HGC. All rights reserved.
//

import UIKit

class LeftMenuCell: UITableViewCell {

    @IBOutlet weak var menuTitle : UILabel!;
    @IBOutlet weak var menuImageView : UIImageView!;
    
    override func awakeFromNib() {
        self.selectionStyle = UITableViewCell.SelectionStyle.default;
        let bgColorView = UIView.init();
        bgColorView.backgroundColor = UIColor.lightGray;
        self.selectedBackgroundView = bgColorView;
        self.menuTitle.font = Font.regularFontLarge()
        self.menuTitle.textColor = UIColor.init(white: 0.92, alpha: 1.0)
    }
}
