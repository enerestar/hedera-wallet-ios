//
//  HGTextField.swift
//  HGCApp
//
//  Created by Surendra  on 26/10/17.
//  Copyright © 2017 HGC. All rights reserved.
//

import UIKit

class HGTextField: UITextField {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.updateUI()
    }
    
    func updateUI() {
        self.backgroundColor = UIColor.clear
        self.textColor = UIColor.white
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.white.cgColor
        self.textColor = Color.primaryTextColor()
        self.font = Font.lightFontLarge()
        self.borderStyle = .none
        
        let paddingViewLeft = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 10, height: 1))
        self.leftView = paddingViewLeft
        self.leftViewMode = .always
        
        let paddingViewRight = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 10, height: 1))
        self.rightView = paddingViewRight
        self.rightViewMode = .always
    }
    
}
