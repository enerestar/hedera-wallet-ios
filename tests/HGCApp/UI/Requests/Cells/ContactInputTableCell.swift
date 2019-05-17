//
//  ContactInputTableCell.swift
//  HGCApp
//
//  Created by Surendra  on 12/12/17.
//  Copyright © 2017 HGC. All rights reserved.
//

import UIKit

protocol ContactInputTableCellDelegate : class {
    func contactInputTableCellDidChange(_ cell:ContactInputTableCell, text:String)
}

class ContactInputTableCell: UITableViewCell , UITextFieldDelegate {

    @IBOutlet weak var captionLabel : UILabel!
    @IBOutlet weak var textField : UITextField!
    weak var delegate: ContactInputTableCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        HGCStyle.regularCaptionLabel(self.captionLabel)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.delegate?.contactInputTableCellDidChange(self, text: textField.text!)
        textField.resignFirstResponder()
        return false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = Color.pageBackgroundColor()
        self.contentView.backgroundColor = Color.pageBackgroundColor()
    }
}
