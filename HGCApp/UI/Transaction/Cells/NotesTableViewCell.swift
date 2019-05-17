//
//  NotesTableViewCell.swift
//  HGCApp
//
//  Created by Surendra  on 11/12/17.
//  Copyright © 2017 HGC. All rights reserved.
//

import UIKit

protocol NotesTableViewCellDelegate : class {
    func notesTableViewCellDidChange(_ cell:NotesTableViewCell, text:String)
    func notesTableViewCellShouldUpdateNewText(_ cell:NotesTableViewCell, text:String) -> Bool
}

class NotesTableViewCell: UITableViewCell, UITextViewDelegate {

    @IBOutlet weak var captionLabel : UILabel!
    @IBOutlet weak var textView : UITextView!
    weak var delegate: NotesTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.clipsToBounds = true
        self.captionLabel.text = NSLocalizedString("NOTE", comment: "")
        HGCStyle.regularCaptionLabel(self.captionLabel)
        self.textView.font = Font.regularFontMedium()
        self.textView.textColor = Color.primaryTextColor()
        let toolBar = HGCKeyboardToolBar.toolBarWithResponder(self.textView)
        self.textView.inputAccessoryView = toolBar
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.delegate?.notesTableViewCellDidChange(self, text: textView.text)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let textViewStr = textView.text! as NSString
        let newStr = textViewStr.replacingCharacters(in: range, with: text)
        let shouldUpdate = self.delegate?.notesTableViewCellShouldUpdateNewText(self, text: newStr) ?? true
        return shouldUpdate
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = Color.pageBackgroundColor()
        self.contentView.backgroundColor = Color.pageBackgroundColor()
    }
}
