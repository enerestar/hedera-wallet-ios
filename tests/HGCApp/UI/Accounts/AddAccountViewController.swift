//
//  AddAccountViewController.swift
//  HGCApp
//
//  Created by Surendra  on 28/11/17.
//  Copyright © 2017 HGC. All rights reserved.
//

import UIKit

extension Notification.Name {
    static let onNewAccountCreated = Notification.Name("onNewAccountCreated")
}

class AddAccountViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var nickNameTextField : UITextField!
    @IBOutlet weak var nickNameCaptionLabel : UILabel!
    @IBOutlet weak var hiddenSwitch : HGCSwitch!
    @IBOutlet weak var accountDetailContainer : UIView!
    @IBOutlet weak var addAccountViewContainer : UIView!
    

    var acountDetailView : AccountDetailView?
    
    static func getInstance() -> AddAccountViewController {
        return Globals.mainStoryboard().instantiateViewController(withIdentifier: "addAccountViewController") as! AddAccountViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.acountDetailView = AccountDetailView.getInstance()
        self.accountDetailContainer.addContentView(self.acountDetailView)
        self.accountDetailContainer.backgroundColor = Color.pageBackgroundColor()
        self.accountDetailContainer.superview?.backgroundColor = Color.pageBackgroundColor()
        self.addAccountViewContainer.backgroundColor = Color.pageBackgroundColor()
        HGCStyle.regularCaptionLabel(self.nickNameCaptionLabel)
        hiddenSwitch.setText(NSLocalizedString("HIDDEN", comment: ""))
        self.title = NSLocalizedString("ADD ACCOUNT", comment: "")
        //self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "icon-close"), style: .plain, target: self, action: #selector(onCloseButtonTap))
        self.navigationItem.hidesBackButton = true
    }
    
    @IBAction func onDoneButtonTap() {
        let nickName = self.nickNameTextField.text?.trim()
        if nickName != nil && !(nickName?.isEmpty)! {
            if let account = HGCWallet.masterWallet()?.createNewAccount() {
                account.name = nickName
                account.isHidden = self.hiddenSwitch.isOn
                CoreDataManager.shared.saveContext()
                self.acountDetailView?.setAccount(account)
                self.acountDetailView?.nickNameTextField.isEnabled = false
                self.acountDetailView?.hiddenSwitch?.isEnabled = false
                self.accountDetailContainer.superview?.isHidden = false
                self.addAccountViewContainer.isHidden = true
                self.title = NSLocalizedString("Account Created", comment: "")
                self.view.endEditing(true)
                NotificationCenter.default.post(name: .onNewAccountCreated, object: nil, userInfo: nil)
            }
            
        } else {
            Globals.showGenericErrorAlert(title: NSLocalizedString("Please give a nickname", comment: ""), message: "")
        }
    }
    
    @objc func onCloseButtonTap() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}
