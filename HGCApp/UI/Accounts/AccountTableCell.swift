//
//  AccountTableCell.swift
//  HGCApp
//
//  Created by Surendra  on 23/11/17.
//  Copyright © 2017 HGC. All rights reserved.
//

import UIKit

class AccountTableCell: UITableViewCell {

    @IBOutlet weak var titleLabel : UILabel!
    @IBOutlet weak var addressLabel : UILabel!
    @IBOutlet weak var hgcBalanceLabel : UILabel!
    @IBOutlet weak var usdBalanceLabel : UILabel!
    @IBOutlet weak var lastTxnLabel : UILabel!
    @IBOutlet weak var hgcLabel : UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.titleLabel.font = Font.lightFontVeryLarge()
        self.titleLabel.textColor = Color.primaryTextColor()
        
        self.addressLabel.font = Font.lightFontLarge()
        self.addressLabel.textColor = Color.secondaryTextColor()
        
        self.hgcBalanceLabel.font = Font.lightFontVeryLarge()
        self.hgcBalanceLabel.textColor = Color.primaryTextColor()
        
        self.usdBalanceLabel.font = Font.lightFontLarge()
        self.usdBalanceLabel.textColor = Color.secondaryTextColor()
        
        self.lastTxnLabel.font = Font.lightFontSmall()
        self.lastTxnLabel.textColor = Color.secondaryTextColor()
        
        self.hgcLabel.font = self.hgcBalanceLabel.font
        self.hgcLabel.text = kHGCCurrencySymbol
        self.hgcLabel.textColor = self.hgcBalanceLabel.textColor
    }
    
    func setAccount(_ account:HGCAccount) {
        let accountName = account.name ?? NSLocalizedString("Unknown", comment: "")
        self.titleLabel.text = accountName
        self.addressLabel.text = NSLocalizedString("Ending in ...", comment: "")+account.publicKeyString().substringFromEnd(length: 6)
        let nanoCoins = account.balance
        self.hgcBalanceLabel.text = nanoCoins.toCoins().formatHGCShort()
        self.usdBalanceLabel.text = CurrencyConverter.shared.convertTo$value(nanoCoins).format$()
        self.lastTxnLabel.text = ""
        if let lastTxn = account.getAllTxn().first {
            var dateStr = ""
            if let date = lastTxn.createdDate {
                dateStr = date.toString()
            }
            self.lastTxnLabel.text = "\(NSLocalizedString("Last transaction", comment: "")) " + dateStr
        }
    }

}
