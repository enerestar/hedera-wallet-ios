//
//  TxnDetailsAddressTableCell.swift
//  HGCApp
//
//  Created by Surendra  on 26/12/17.
//  Copyright © 2017 HGC. All rights reserved.
//

import UIKit

protocol TxnDetailsAddressTableCellDelegate : class {
    func txnAddressTableViewCellDidTapActionButton(_ cell:TxnDetailsAddressTableCell)
    func txnAddressTableViewCellDidTapCopyButton(_ cell:TxnDetailsAddressTableCell)
    func txnAddressTableViewCellDidChange(_ cell:TxnDetailsAddressTableCell, name:String)
}

class TxnDetailsAddressTableCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var captionLabel : UILabel!
    @IBOutlet weak var keyLabel : HGCLabel!
    @IBOutlet weak var nameLabel : UITextField!
    @IBOutlet weak var copyButton : UIButton!
    var actionButton : UIButton!
    
    var allowEditing = false
    
    weak var delegate: TxnDetailsAddressTableCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.clipsToBounds = true
        HGCStyle.regularCaptionLabel(self.captionLabel)
        self.copyButton.isHidden = true
        self.copyButton.addTarget(self, action: #selector(self.onCopyButtonTap), for: .touchUpInside)
        
        self.actionButton = UIButton.init()
        self.actionButton.addTarget(self, action: #selector(self.onActionButtonTap), for: .touchUpInside)
        self.actionButton.setTitle(NSLocalizedString("VERIFY", comment: ""), for: .normal)
        self.actionButton.setTitleColor(Color.selectedTintColor(), for: .normal)
        self.actionButton.titleLabel?.font = Font.regularFontMedium()
        self.actionButton.sizeToFit()
        self.actionButton.frame.size.width = self.actionButton.frame.size.width+10
        self.nameLabel.rightView = self.actionButton
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = Color.pageBackgroundColor()
        self.contentView.backgroundColor = Color.pageBackgroundColor()
    }
    
    @objc func onActionButtonTap() {
        self.delegate?.txnAddressTableViewCellDidTapActionButton(self)
    }
    
    @objc func onCopyButtonTap() {
        self.delegate?.txnAddressTableViewCellDidTapCopyButton(self)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return self.allowEditing
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newStr = textField.text?.replace(string: string, inRange: range)
        self.delegate?.txnAddressTableViewCellDidChange(self, name: newStr!)
        return true
    }
}
