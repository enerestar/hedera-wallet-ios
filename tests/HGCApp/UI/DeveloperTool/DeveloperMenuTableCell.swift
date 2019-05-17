//
//  DeveloperMenuTableCell.swift
//  HGCApp
//
//  Created by Surendra on 16/06/18.
//  Copyright © 2018 HGC. All rights reserved.
//

import UIKit

class DeveloperMenuTableCell: UITableViewCell {
    @IBOutlet weak var menuTitle : UILabel!
    @IBOutlet weak var btnSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.menuTitle.font = Font.regularFont(16)
        self.menuTitle.textColor = Color.primaryTextColor()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
