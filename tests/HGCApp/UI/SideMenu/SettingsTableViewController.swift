//
//  SettingsTableViewController.swift
//  HGCApp
//
//  Created by Surendra  on 17/12/17.
//  Copyright © 2017 HGC. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet weak var nameCaptionLabel : UILabel!;
    @IBOutlet weak var pinCaptionLabel : UILabel!;
    
    @IBOutlet weak var nameTextField : UITextField!;
    @IBOutlet weak var pinOldTextField : UITextField!;
    @IBOutlet weak var pinNewTextField : UITextField!;
    @IBOutlet weak var enablePinSwitch : HGCSwitch!;
    @IBOutlet weak var enableQueryOnSwipeDownSwitch : HGCSwitch!;


    static func getInstance() -> SettingsTableViewController {
        return Globals.mainStoryboard().instantiateViewController(withIdentifier: "settingsTableViewController") as! SettingsTableViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("PROFILE", comment: "")
        self.navigationItem.hidesBackButton = true
        
        self.tableView.separatorStyle = .none
        self.tableView.allowsSelection = false
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableView.automaticDimension
        
        HGCStyle.regularCaptionLabel(self.nameCaptionLabel)
        self.nameTextField.text = AppSettings.getAppUserName()
        
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = Color.pageBackgroundColor()
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.backgroundView = UIView.init()
            header.backgroundView?.backgroundColor = Color.pageBackgroundColor()
            header.textLabel?.textColor = Color.primaryTextColor()
            header.textLabel?.font = Font.regularFontLarge()
        }
    }
    
//    override func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
//        if let header = view as? UITableViewHeaderFooterView {
//            header.backgroundView = UIView.init()
//            header.backgroundView?.backgroundColor = Color.pageBackgroundColor()
//            header.textLabel?.textColor = Color.primaryTextColor()
//            header.textLabel?.font = Font.regularFontLarge()
//        }
//    }

    @IBAction func onChangePinButtonTap() {
        
    }
    
    @IBAction func onEnableBiometricValueChanged() {
       
    }
    
    @IBAction func onEnableQueryOnSwipeSwitchValueChanged() {
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newStr = textField.text?.replace(string: string, inRange: range)
        if self.nameTextField == textField {
            AppSettings.setAppUserName(newStr!)
            
        } else if textField == self.pinOldTextField || textField == self.pinNewTextField {
            if newStr!.count > 4 {
                return false
            }
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
