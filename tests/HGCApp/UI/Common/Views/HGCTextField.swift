//
//  HGCTextField.swift
//  HGCApp
//
//  Created by Surendra  on 07/12/17.
//  Copyright © 2017 HGC. All rights reserved.
//

import UIKit

class HGCTextField: UITextField {

    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.white
        self.borderStyle = .none
        self.layer.borderColor = Color.boxBorderColor().cgColor
        self.layer.borderWidth = 1
        self.textColor = Color.primaryTextColor()
        self.font = Font.lightFontLarge()
        self.leftViewMode = .always
        self.rightViewMode = .always
        let toolBar = HGCKeyboardToolBar.toolBarWithResponder(self)
        self.inputAccessoryView = toolBar
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize.init(width: 100, height: 34)
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.editingRect(forBounds: bounds)
        if rect.origin.x == 0 {
            rect.origin.x = 10
            rect.size.width = rect.size.width - 10
        }
        if  rect.maxX ==  bounds.width {
            rect.size.width = rect.size.width - 10
        }
        return rect
    }
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return self.textRect(forBounds:bounds)
    }
}
