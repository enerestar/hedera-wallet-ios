//
//  VerifyAliasViewController.swift
//  HGCApp
//
//  Created by Surendra  on 04/12/17.
//  Copyright © 2017 HGC. All rights reserved.
//

import UIKit

class VerifyAliasViewController: UIViewController {

    @IBOutlet weak var nameLabel : UILabel!
    @IBOutlet weak var addressLabel : UILabel!
    @IBOutlet weak var messageLabel : UILabel!
    @IBOutlet weak var bgView : UIView!

    var name : String!
    var address : String!
    static func getInstance(name: String, address:String) -> VerifyAliasViewController {
        let vc = Globals.mainStoryboard().instantiateViewController(withIdentifier: "verifyAliasViewController") as! VerifyAliasViewController
        vc.name = name
        vc.address = address
        return vc
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "icon-close"), style: .plain, target: self, action: #selector(onCancelButtonTap))
        self.title = NSLocalizedString("VERIFY ALIAS", comment: "")
        self.navigationItem.hidesBackButton = true
        self.nameLabel.textColor = Color.primaryTextColor()
        self.nameLabel.font = Font.lightFontMedium()
        self.addressLabel.textColor = Color.primaryTextColor()
        self.addressLabel.font = Font.lightFontSmall()

        self.messageLabel.textColor = Color.veryDarkTextColor()
        self.messageLabel.font = Font.regularFontSmall()
        self.bgView.backgroundColor = Color.pageBackgroundColor()
        
        self.nameLabel.text = self.name
        self.addressLabel.text = self.address
    }

    @IBAction func onVerfyButtonTap() {
        let contact = HGCContact.addAlias(name: self.name, address: self.address)
        contact?.verified = true
        CoreDataManager.shared.saveContext()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onCancelButtonTap() {
        self.navigationController?.popViewController(animated: true)
    }
}
