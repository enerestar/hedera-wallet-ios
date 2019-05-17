//
//  AddressOptionsTableCell.swift
//  HGCApp
//
//  Created by Surendra  on 10/12/17.
//  Copyright © 2017 HGC. All rights reserved.
//

import UIKit

protocol AddressOptionsTableCellDelegate : class {
    func optionsTableViewCellDidTapatIndex(_ cell:AddressOptionsTableCell, index:Int)
}

class AddressOptionsTableCell: UITableViewCell {

    @IBOutlet weak var captionLabel : UILabel!
    @IBOutlet weak var button1 : UIButton?
    @IBOutlet weak var button2 : UIButton?
    @IBOutlet weak var button3 : UIButton?
    
    weak var delegate: AddressOptionsTableCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        HGCStyle.regularCaptionLabel(self.captionLabel)
    }
    
    func setTitle(_ title:String, atIndex:Int) {
        switch atIndex {
        case 0:
            button1?.setTitle(title, for: .normal)
        case 1:
            button2?.setTitle(title, for: .normal)
        case 2:
            button3?.setTitle(title, for: .normal)
        default:
            break
        }
    }
    
    func removeButtonAtIndex(index:UInt8) {
        self.button2?.removeFromSuperview()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = Color.pageBackgroundColor()
        self.contentView.backgroundColor = Color.pageBackgroundColor()
    }
    
    @IBAction func handleTapOnButton(_ sender:UIButton) {
        self.delegate?.optionsTableViewCellDidTapatIndex(self, index: sender.tag)
    }
}
