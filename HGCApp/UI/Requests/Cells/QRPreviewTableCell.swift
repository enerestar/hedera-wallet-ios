//
//  QRPreviewTableCell.swift
//  HGCApp
//
//  Created by Surendra  on 12/12/17.
//  Copyright © 2017 HGC. All rights reserved.
//

import UIKit

protocol QRPreviewTableCellDelegate : class {
    func qrPreviewTableCellDidCancel(_ cell:QRPreviewTableCell)
}

class QRPreviewTableCell: UITableViewCell {
    
    @IBOutlet weak var captionLabel : UILabel!
    @IBOutlet weak var qrImageView : UIImageView!
    
    weak var delegate: QRPreviewTableCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        captionLabel.text = ""
        HGCStyle.regularCaptionLabel(self.captionLabel)
    }
    
    @IBAction func onCancelButtonTap() {
        self.delegate?.qrPreviewTableCellDidCancel(self)
    }
    
    func setString(_ str:String) {
        var qrCode = QRCode.init(str)
        qrCode?.size = CGSize.init(width: qrImageView.frame.size.width, height: qrImageView.frame.size.height);
        self.qrImageView.image = qrCode?.image
        Logger.instance.log(message: str, event: .d)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = Color.pageBackgroundColor()
        self.contentView.backgroundColor = Color.pageBackgroundColor()
    }
}
