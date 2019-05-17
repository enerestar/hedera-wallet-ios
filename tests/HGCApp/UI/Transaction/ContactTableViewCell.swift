//
//  ContactTableViewCell.swift
//  HGCApp
//
//  Created by Surendra  on 18/12/17.
//  Copyright © 2017 HGC. All rights reserved.
//

import UIKit

class ContactTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel : UILabel!
    @IBOutlet weak var addressLabel : UILabel!
    @IBOutlet weak var verifiedLabel : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.nameLabel.font = Font.regularFontLarge()
        self.addressLabel.font = Font.regularFontMedium()
        self.verifiedLabel.font = Font.lightFontVerySmall()
        
        self.nameLabel.textColor = Color.primaryTextColor()
        self.addressLabel.textColor = Color.primaryTextColor()
        self.verifiedLabel.textColor = Color.negativeColor()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = Color.pageBackgroundColor()
        self.contentView.backgroundColor = Color.pageBackgroundColor()
    }
}
