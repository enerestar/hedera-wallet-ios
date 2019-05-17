//
//  HGCKeyboardToolBar.swift
//  HGCApp
//
//  Created by Surendra  on 21/12/17.
//  Copyright © 2017 HGC. All rights reserved.
//

import UIKit

class HGCKeyboardToolBar: UIToolbar {
    
    weak var reponderObj : UIResponder?
    
    static func toolBarWithResponder(_ r: UIResponder ) -> HGCKeyboardToolBar {
        
        let bar = HGCKeyboardToolBar.init(frame: CGRect.init(x: 0, y: 0, width: 44, height: 44))
        bar.reponderObj = r
        bar.setup()
        return bar
    }
    
    private func setup() {
        let flexi = UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem.init(title: "Dismiss", style: .plain, target: self, action: #selector(self.onDoneTap))
        self.items = [flexi,doneButton]
    }
    
    @objc func onDoneTap() {
        reponderObj?.resignFirstResponder()
    }
    
}
