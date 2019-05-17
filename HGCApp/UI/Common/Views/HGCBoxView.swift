//
//  HGCBoxView.swift
//  HGCApp
//
//  Created by Surendra  on 12/12/17.
//  Copyright © 2017 HGC. All rights reserved.
//

import UIKit

class HGCBoxView: UIView {

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
    }
    
    func setupUI() {
        self.backgroundColor = UIColor.white
        self.layer.borderColor = Color.boxBorderColor().cgColor
        self.layer.borderWidth = 1
    }
}
