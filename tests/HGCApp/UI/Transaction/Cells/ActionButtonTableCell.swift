//
//  ActionButtonTableCell.swift
//  HGCApp
//
//  Created by Surendra  on 11/12/17.
//  Copyright © 2017 HGC. All rights reserved.
//

import UIKit

protocol ActionButtonTableCellDelegate : class {
    func actionButtonCellDidTapActionButton(_ cell:ActionButtonTableCell)
}

class ActionButtonTableCell: UITableViewCell {

    @IBOutlet weak var button : UIButton!
    weak var delegate: ActionButtonTableCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setTitle(_ title: String)  {
        button.setTitle(title, for: .normal)
    }
    
    @IBAction func handleTap() {
        self.delegate?.actionButtonCellDidTapActionButton(self)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = Color.pageBackgroundColor()
        self.contentView.backgroundColor = Color.pageBackgroundColor()
    }
}
