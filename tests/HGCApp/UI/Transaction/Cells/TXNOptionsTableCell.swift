//
//  TXNOptionsTableCell.swift
//  HGCApp
//
//  Created by Surendra  on 11/12/17.
//  Copyright © 2017 HGC. All rights reserved.
//

import UIKit

protocol TXNOptionsTableCellDelegate : class {
    func optionsTableCellDidChangeForNotification(_ cell:TXNOptionsTableCell, value:Bool)
    func optionsTableCellDidChangeForNotes(_ cell:TXNOptionsTableCell, value:Bool)
}

class TXNOptionsTableCell: UITableViewCell {
    
    @IBOutlet weak var notificationSwitch : HGCSwitch!
    @IBOutlet weak var notesSwitch : HGCSwitch!
    
    weak var delegate : TXNOptionsTableCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.clipsToBounds = true
        notificationSwitch.setText("REQUEST NOTIFICATION")
        notesSwitch.setText(NSLocalizedString("ADD NOTE", comment: ""))
        
        self.notificationSwitch.addTarget(self, action: #selector(self.onNotificationValueChanged), for: .valueChanged)
        self.notesSwitch.addTarget(self, action: #selector(self.onNotesValueChanged), for: .valueChanged)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = Color.pageBackgroundColor()
        self.contentView.backgroundColor = Color.pageBackgroundColor()
    }
    
    @objc func onNotificationValueChanged() {
        self.delegate?.optionsTableCellDidChangeForNotification(self, value: self.notificationSwitch.isOn)
    }
    
    @objc func onNotesValueChanged() {
        self.delegate?.optionsTableCellDidChangeForNotes(self, value: self.notesSwitch.isOn)
    }
}
